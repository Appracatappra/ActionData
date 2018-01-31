# Action Data Providers

**Action Data Providers** provide light weight, low-level access to several common databases and data formats such as SQLite, JSON, XML, SPON and CloudKit. Results are returned as a key/value dictionary (`ADRecord`) or as an array of key/value dictionaries (`ADRecordSet`).

**Action Data Providers** provide a subset of the full SQL query language (using SQLite's syntax) to data sources that typically don't natively understand SQL (such as JSON, XML and SPON). This allows the developer to work in SQL across data sources.

Optionally, an **Action Data Provider** can be used with a set of `Codable` structures or classes to provide high-level **Object Relationship Management** (ORM) with the Data Provider handling adding, updating or deleting the backing records in the Data Source.


This includes the following:

* [Simple Data Model Example](#Simple-Data-Model-Example) - Provides an example of a simple data model that can be automatically handled using **Action Data Providers**.
* [Complex Data Model Example](#Complex-Data-Model-Example) - Provides an example of a complex set of data models that can be automatically handled using **Action Data Providers**.
* [Swift Portable Object Notation](#Swift-Portable-Object-Notation) - The new **Swift Portable Object Notation** (SPON) data format allows complex data models to be encoded in a portable text string containing both values and types.
* [ADSQLiteProvider](#ADSQLiteProvider) - The `ADSQLiteProvider` provides both light-weight, low-level access to data stored in a SQLite database and high-level access via a **Object Relationship Management** (ORM) model.
* [ADSPONProvider](#ADSPONProvider) - The `ADSPONProvider` provides both light-weight, low-level access to data stored in a **Swift Portable Object Notation** (SPON) database and high-level access via a **Object Relationship Management** (ORM) model.
* [Working with Data Providers](#Working-with-Data-Providers) - Provides a quick overview of working with **Action Data Providers** in your apps. The following topics are covered:
	* [Using the Shared Provider](#Using-the-Shared-Provider)
	* [Opening a Database](#Opening-a-Database)
	* [Duplicating a Data Source](#Duplicating-a-Data-Source)
	* [Deleting a Data Source](#Deleting-a-Data-Source)
	* [Saving Database Changes](#Saving-Database-Changes)
	* [Executing Non-Query Commands](#Executing-Non-Query-Commands)
	* [Querying the Data Source](#Querying-the-Data-Source)
	* [Working with Tables](#Working-with-Tables)
	* [Working with Transactions](#Working-with-Transactions)
* [Object Relationship Management](#Object-Relationship-Management) - Provides a quick overview of working with **Action Data Providers** and custom data models to provide ORM support in your apps. The following topics are covered:
	* [Registering a Table](#Registering-a-Table) 
	* [Updating a Table](#Updating-a-Table)
	* [Checking if a Record Exists](#Checking-if-a-Record-Exists)
	* [Counting Records](#Counting-Records)
	* [Creating a Record with an Automatic ID](#Creating-a-Record-with-an-Automatic-ID)
	* [Creating an Automatic Record ID](#Creating-an-Automatic-Record-ID)
	* [Saving a Record](#Saving-a-Record)
	* [Loading Records](#Loading-Records)
	* [Deleting Records](#Deleting-Records)
	* [Deleting a Table](#Deleting-a-Table)

<a name="Simple-Data-Model-Example"></a>
## Simple Data Model Example

With **Action Codable** and **Action Data Providers**, build your data model objects as simple `struct` or `class` objects and inherit from `ADDataTable`, then use the providers to quickly create, insert, update, delete and maintain the tables and records in the underlying data source. For example:

```swift
import Foundation
import ActionUtilities
import ActionData

class Category: ADDataTable {
    
    enum CategoryType: String, Codable {
	    case local
	    case web
	}
    
    static var tableName = "Categories"
    static var primaryKey = "id"
    static var primaryKeyType: ADDataTableKeyType = .computedInt
    
    var id = 0
    var added = Date()
    var name = ""
    var description = ""
    var enabled = true
    var highlightColor = UIColor.white.toHex()
    var type: CategoryType = .local
    var icon: Data = UIImage(named:"Avatar.png").toData()
    
    required init() {
        
    }
}
```

The above code will create a `Categories` table in the database with a primary key of `id` that will be automatically incremented when the class is written to the database.

All **Action Data Providers** will automatically create a SQL Table from a class instance if one does not already exist. In addition, each provider contains routines to preregister or update the schema classes conforming to the `ADDataTable` protocol which will build or modify the database tables as required.

<a name="Complex-Data-Model-Example"></a>
## Complex Data Model Example 

The following is an example of a complex set of tables that can be manipulated using an **Action Data Provider**:

```swift
import Foundation
import ActionUtilities
import ActionData

struct Address: Codable {
    var addr1 = ""
    var addr2 = ""
    var city = ""
    var state = ""
    var zip = ""
}

class Person: ADDataTable {
    
    static var tableName = "People"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.autoUUIDString
    
    var id = UUID().uuidString
    var firstName = ""
    var lastName = ""
    var addresses: [String:Address] = [:]
    
    required init() {
        
    }
    
    init(firstName: String, lastName:String, addresses: [String:Address] = [:]) {
        self.firstName = firstName
        self.lastName = lastName
        self.addresses = addresses
    }
}

class Group: ADDataTable {
    
    static var tableName = "Groups"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.autoUUIDString
    
    var id = UUID().uuidString
    var name = ""
    var people = ADCrossReference<Person>(name: "PeopleInGroup", leftKeyName: "groupID", rightKeyName: "personID")
    
    required init() {
        
    }
    
    init(name: String, people: [Person] = []) {
        self.name = name
        self.people.storage = people
    }
}
```

If these records are written to a SQLite database using the `ADSQLiteProvider`, the `addresses` property of the `Person` class will be encoded as a single column in the SQL `Person` table. All `Address` class instances will be converted to SPON data and stored in the column.

Because the `Group` class is using a `ADCrossReference` for the `people` property. A cross reference table called `PeopleInGroup` will be created in the SQL database and each `Person` class instance will be written to this table.

While in memory, the `people` class will hold all of the `Person` class instances in a `storage` property.

<a name="Swift-Portable-Object-Notation"></a>
## Swift Portable Object Notation

The new **Swift Portable Object Notation** (SPON) data format that allows complex data models to be encoded in a portable text string that encodes not only property keys and data, but also includes type information about the encoded data.

The portable, human-readable string format encodes values with a single character _type designator_ as follows:

* `%` – `Bool`
* `!` – `Int`
* `$` – `String`
* `^` – `Float`
* `&` – `Double`
* `*` – Embedded `NSData` or `Data` value.
 
Additionally, embedded arrays will be in the `@array[...]` format and embedded dictionaries in the `@obj:type<...>` format.

So a populated `Address` struct above could be represented in SPON as:

```swift
@obj:Address<state$=`TX` city$=`Seabrook` addr1$=`25 Nasa Rd 1` zip$=`77586` addr2$=`Apt #123`>
```

SPON is used heavily throughout the **Action Data Providers** to transport Swift data to and from the given data sources.

<a name="ADSQLiteProvider"></a>
## ADSQLiteProvider

The `ADSQLiteProvider` provides both light-weight, low-level access to data stored in a SQLite database and high-level access via a **Object Relationship Management** (ORM) model. Use provided functions to read and write data stored in a `ADRecord` format from and to the database using SQL statements directly.
  
Optionally, pass a class instance conforming to the `ADDataTable` protocol to the `ADSQLiteProvider` and it will automatically handle reading, writing and deleting data as required.
 
### Example:

```swift
let addr1 = Address(addr1: "PO Box 1234", addr2: "", city: "Houston", state: "TX", zip: "77012")
let addr2 = Address(addr1: "25 Nasa Rd 1", addr2: "Apt #123", city: "Seabrook", state: "TX", zip: "77586")
 
let p1 = Person(firstName: "John", lastName: "Doe", addresses: ["home":addr1, "work":addr2])
let p2 = Person(firstName: "Sue", lastName: "Smith", addresses: ["home":addr1, "work":addr2])
 
let group = Group(name: "Employees", people: [p1, p2])
try provider.save(group)
```

<a name="ADSPONProvider"></a>
## ADSPONProvider

The `ADSPONProvider` provides both light-weight, low-level access to data stored in a **Swift Portable Object Notation** (SPON) database and high-level access via a **Object Relationship Management** (ORM) model. Use provided functions to read and write data stored in a `ADRecord` format from and to the database using SQL statements directly.
 
 Optionally, pass a class instance conforming to the `ADDataTable` protocol to the `ADSPONProvider` and it will automatically handle reading, writing and deleting data as required.
 
### Example:
 
```swift
let addr1 = Address(addr1: "PO Box 1234", addr2: "", city: "Houston", state: "TX", zip: "77012")
let addr2 = Address(addr1: "25 Nasa Rd 1", addr2: "Apt #123", city: "Seabrook", state: "TX", zip: "77586")
 
let p1 = Person(firstName: "John", lastName: "Doe", addresses: ["home":addr1, "work":addr2])
let p2 = Person(firstName: "Sue", lastName: "Smith", addresses: ["home":addr1, "work":addr2])
 
let group = Group(name: "Employees", people: [p1, p2])
try provider.save(group)
```

<a name="Working-with-Data-Providers"></a>
## Working with Data Providers

Because all **Action Data Providers** conform to the `ADDataProvider` protocol, they provide the same properties and functions for working with their base data types (SQLite, SPON, etc.) and because of this, all **Action Data Providers** are interchangeable.

So you can start developing locally using a SQLite database and a `ADSQLiteProvider`, then later switch to CloudKit and a `ADCloudKitProvider` without have to change any of your other code.

Additionally, **Action Data Providers** can be used to move data from one source to another. For example, download data from the web in SPON using a `ADSPONProvider` and save it to a local SQLite database using a `ADSQLiteProvider`, all with a minimal of code.

<a name="Using-the-Shared-Provider"></a>
### Using the Shared Provider

All **Action Data Providers** provide a common, shared instance via the static `shared` property. For app’s that are working with a single database, they can use this instance instead of creating their own instance of a provider directly. For example:

```swift
// Use shared instance
let provider = ADSQLProvider.shared

// Use custom instance
Let myProvider = ADSQLProvider()
```

<a name="Opening-a-Database"></a>
### Opening a Database

The `openSource` function opens the given SQLite database file for the data provider from either the app’s **Document** or **Bundle** directories. If opening a database from the **Document** directory and it does not exist, the database will automatically be created. If opening a database from the **Bundle** directory for write access, the database will first be copied to the **Document** directory (if a copy doesn’t already exist there), and the **Document** directory copy of the database will be opened. For example:

```swift
// Open the database
do {
	// Creating and opening a database in the Document directory.
    try provider.openSource("Test.db")
    print("Database Location: \(provider.path)")
} catch {
    print("Unable to open requested sample database 'Test.db'.")
}
```

If you wanted to use a preconfigured SQLite database as a "template" an app's database, include it in the app's **Bundle** and use the following command to open it:

```swift
// Open the database
do {
	// Copying a template from the Bundle.
    try provider.openSource("Test.db", fromBundle: true, readOnly: false)
    print("Database Location: \(provider.path)")
} catch {
    print("Unable to open requested sample database 'Test.db'.")
}
```

You can also include a read only database in the app's **Bundle** access it directly using:

```swift
// Open the database
do {
	// Open a read only Bundle database.
    try provider.openSource("Test.db", fromBundle: true, readOnly: true)
    print("Database Location: \(provider.path)")
} catch {
    print("Unable to open requested sample database 'Test.db'.")
}
```

Optionally, you can use the `createSource` function that creates the given SQLite database file for the data provider in the app’s **Document** directory. If the database file already exists, it will be opened instead:

```swift
// Open the database
do {
	// Create a new database and open it.
    try provider.createSource("Test.db")
    print("Database Location: \(provider.path)")
} catch {
    print("Unable to create or open requested sample database 'Test.db'.")
}
```

<a name="Duplicating-a-Data-Source"></a>
### Duplicating a Data Source

You can use the `saveSource` function to close the currently open SQLite database, copy it to a new filename and reopen the database under the new name:

```swift
// Duplicate the database
do {
	// Open an existing database.
    try provider.openSource("Test.db")
    ...
    
    // Save under a new name and reopen
    try provider.saveSource("New.bd")
} catch {
    // Handle error
    ...
}
```

<a name="Deleting-a-Data-Source"></a>
### Deleting a Data Source

For writable databases stored in the app’s document directory, use the `deleteSource` function to delete the data source with the specified file name. For example:

```swift
// Delete the database
try ADSQLiteProvider.shared.deleteSource("MyDatabase.db")
```

<a name="Saving-Database-Changes"></a>
### Saving Database Changes

The `persist` function is used to write in-memory Data Provider content to persistent data storage. This command has no affect on a SQLite database. For example:

```swift
// Save current changes
ADSPONProvider.shared.persist()
```

When you are finished with a data source, you should always call the `closeSource()` function. It will write any pending changes to the persistent data storage and close the database. For example:

```swift
// Save current changes
ADSPONProvider.shared.closeSource()
```
<a name="Executing-Non-Query-Commands"></a>
### Executing Non-Query Commands

Use the `execute` function to execute SQL (non-query) command with (optional) parameters and return result code. For example:

```swift
let sql = "CREATE TABLE IF NOT EXISTS Person (`ID` INTEGER, `Name` STRING)"
try ADSQLiteProvider.shared.execute(sql)
```

If executing an `INSERT` command of a record with an `INTEGER` id, the last inserted ID will be returned. For `DELETE` and `UPDATE` commands, a count of number of records modified will be returned. All other commands will return `1` on success and `-1` on failure.

<a name="Querying-the-Data-Source"></a>
### Querying the Data Source

Use the `query` function to run an SQL query with parameters and returns an array of dictionaries (`ADRecord` or `ADRecordSet`) where the keys are the column names and the values are the data returned. For example:

 
```swift
let provider = ADSPONProvider.shared
let record = try provider.query("SELECT * FROM Categories WHERE id = ?", withParameters: [1])
print(record["name"])
```

<a name="Working-with-Tables"></a>
### Working with Tables

**Action Data Providers** provide several functions for working with the tables stored in a data source. The `tableExists` test to see if a table exists in the data source:

```swift
// Does table exist?
let exists = try ADSQLiteProvider.shared.tableExists("Person)
if exists {
	...
}
```

The `getTableSchema` function returns all information about a given table in the data source including all of the columns and their types:

```swift
// Get table information
let schema = try ADSQLiteProvider.shared.getTableSchema(forTableName: "Category")
```

Use the `countRows` function to count the number of records in a given SQLite database table, optionally filtered by a given set of constraints. The optional filter criteria to be used in fetching the data. Specify the filter criteria in the form of a valid SQLite `WHERE` clause (without the actual `WHERE` keyword). If this parameter is omitted or a blank string is provided, all rows will be fetched.

Optionally, pass in an array of parameters as they appear the SQL statement (indicated by `?` in the SQL Statement) to limit returned records. For example:

```swift
// Get record count
let count = try ADSQLiteProvider.shared.countRows(inTable: "Person", filteredBy: "ID = ?", withParameters: [1])
```

Use the `lastIntID` function to get the largest used number for the given integer primary key of the given table:

```swift
// Get last person ID
let lastID = try ADSQLiteProvider.shared.lastIntID(forTable: "Person", withKey: "ID")
```

Use the `lastAutoID` property to get the last auto generated ID for a given table:

```swift
// Get last auto generated ID
let lastID = ADSQLiteProvider.shared.lastAutoID(forTable: "Category")
```

<a name="Working-with-Transactions"></a>
### Working with Transactions

**Action Data Providers** provide several functions for working with transactions in a data source. Use `beginTransaction` to start an explicit transaction to process a batch of database changes. Once started, the transaction will remain open until it is either committed (via `endTransaction`) or rolled-back (via `rollbackTransaction`). For example:

```swift
do {
	let sql = "CREATE TABLE IF NOT EXISTS Person (`ID` INTEGER, `Name` STRING)"
	ADSQLiteProvider.shared.beginTransaction()
	try ADSQLiteProvider.shared.execute(sql)
	ADSQLiteProvider.shared.endTransaction()
} catch {
	ADSQLiteProvider.shared.rollbackTransaction()
}
```

Use `rollbackTransaction` to end the current transaction (opened using `beginTransaction`) and undo any changes made to the database since the transaction was opened. Use `endTransaction` to attempt to commit any changes to the database and close the current transaction that was opened using `beginTransaction`.

<a name="Object-Relationship-Management"></a>
## Object Relationship Management

All **Action Data Providers** can be used with a set of `Codable` structures or classes to provide high-level **Object Relationship Management** (ORM) with the Data Provider handling adding, updating or deleting the backing records in the Data Source.

<a name="Registering-a-Table"></a>
### Registering a Table

You can preregister a Data Model (by using the classes `.self` property) with an **Action Data Provider** using the `registerTableSchema` function. When preregistering, any tables required to store the object (or any child objects) will be created if they don't already exist. For example:

```swift
try ADSQLiteProvider.shared.registerTableSchema(Category.self)
``` 

This is typically done when the app first launches after the data source has been opened.

<a name="Updating-a-Table"></a>
### Updating a Table

Use the `updateTableSchema` to make any make any changes to the underlying tables that support a Data Model if you have changed the structure of the model. If the table does not exist, it will attempt to be registered with the database. For example:

```swift
try ADSQLiteProvider.shared.updateTableSchema(Category.self)
```

During the update, the existing table will be renamed, a new instance will be created and the data that still matches the structure will be copied across. If any new columns have been added, the default values will be set from the given defaults.

**WARNING!** If you remove columns from a Data Model, the data in those columns will be permanently delete from the database.

<a name="Checking-if-a-Record-Exists"></a>
### Checking if a Record Exists

The `hasRow` function checks to see if a record for a given Data Model exists in the data source with the given primary key. For example:

```swift
let found = try ADSQLiteProvider.shared.hasRow(forType: Person.self, matchingPrimaryKey: 1)
```

<a name="Counting-Records"></a>
### Counting Records

The `rowCount` function returns the count of rows (records) in the table, or the count of rows matching a specific filter criteria, if one was provided. For example:

```swift
let count = try ADSQLiteProvider.shared.rowCount(forType: Person.self)
```

<a name="Creating-a-Record-with-an-Automatic-ID"></a>
### Creating a Record with an Automatic ID

Use the `make` function to create an instance of the given `ADDataTable` class automatically setting the **primaryKey** field based on the value of the **primaryKeyType**. For example:

```swift
var category = try ADSQLiteProvider.shared.make(Category.self)
```

Because the `Category` class (shown above) has the following definition:

```swift
static var tableName = "Categories"
static var primaryKey = "id"
static var primaryKeyType: ADDataTableKeyType = .computedInt
```

The above command would create a new instance of the `Category` class and automatically set the `id` property to the next highest, unused integer ID (for example `5` if four records already existed in the data source).

<a name="Creating-an-Automatic-Record-ID"></a>
### Creating an Automatic Record ID

The `makeID` function returns a value for the **primaryKey** field based on the value of the **primaryKeyType** for a class conforming to the `ADDataTable` protocol. For example:

```swift
let id = ADSQLiteProvider.shared.makeID(Category.self) as! Int
```

This is an optional way of getting the next automatic ID as an addition to the `make` function presented above.

<a name="Saving-a-Record"></a>
### Saving a Record

The `save` function saves the given class conforming to the `ADDataTable` protocol to the database. If the data source does not contain a table named in the **tableName** property, one will be created first. If a record is not on file matching the **primaryKey** value, a new record will be created, else the existing record will be updated. For example:

```swift
var category = Category()
try ADSQLiteProvider.shared.save(category)
```

Additionally, you can save a collection of records at the same time:

```swift
let c1 = Category()
let c2 = Category()
try ADSQLiteProvider.shared.save([c1, c2])
```

<a name="Loading-Records"></a>
### Loading Records

The `getRows` function returns rows from the data source for the given class type optionally filtered, sorted and limited to a specific range of results. For example:

```swift
// Return all people from data source
let records = try ADSQLiteProvider.shared.getRows(ofType: Person.self)
```

The optional filter criteria to be used in fetching the data. Specify in the form of a valid SQL `WHERE` clause (without the actual `WHERE` keyword). If this parameter is omitted or a blank string is provided, all rows will be fetched. 

The optional sorting criteria to be used in fetching the data. Specify in the form of a valid SQL `ORDER BY` clause (without the actual `ORDER BY` keyword). If this parameter is omitted or a blank string is provided, no sorting will be applied.

The starting index for the returned results. If omitted or zero, the result set starts with the first record.

Optionally, you can use a SQL statement directly to return records:

```swift
let sql = "SELECT * FROM Person WHERE ID = ?"
let records = try ADSQLiteProvider.shared.getRows(ofType: Person.self, matchingSQL: sql, withParameters: [1])
```

Or you can return a single record instance for a given primary key using:

```swift
let person = try ADSQLiteProvider.shared.getRow(ofType: Person.self, forPrimaryKeyValue: 1)
```

Or you can return a single instance by its location within the data source using:

```swift
let category = try ADSQLiteProvider.shared.getRow(ofType: Category.self, atIndex: 10)
```

<a name="Deleting-Records"></a>
### Deleting Records

Use the `delete` function to delete the row matching the given record from the data source. For example:

```swift
let category = try ADSQLiteProvider.shared.getRow(ofType: Category.self, forPrimaryKeyValue: 10)
try ADSQLiteProvider.shared.delete(category)
```

Or you can delete a group of records using:

```swift
let c1 = try ADSQLiteProvider.shared.getRow(ofType: Category.self, forPrimaryKeyValue: 10)
let c2 = try ADSQLiteProvider.shared.getRow(ofType: Category.self, forPrimaryKeyValue: 5)
try ADSQLiteProvider.shared.delete([c1, c2])
```

<a name="Deleting-a-Table"></a>
### Deleting a Table

Use the `dropTable` function to drop the underlying table from the data source, completely removing all stored data in the table as well as the table itself. For example:

```swift
try ADSQLiteProvider.shared.dropTable(Category.self)
```