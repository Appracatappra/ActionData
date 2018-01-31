# Action Codable
 
**Action Codable** controls provide support for several common databases and data formats such as SQLite, JSON, XML and CloudKit using Swift 4's new `Codable`, `Encodable` and `Decodable` protocols to move information between your data models and our portable `ADRecord` and `ADRecordSet` formats.

**Action Codable** includes the following elements:

* [ADInstanceArray](#ADInstanceArray) - Defines a passable array of values used as temporary storage when encoding or decoding an Action Data class. Useful when creating your own custom Encoders and Decoders.
* [ADInstanceDictionary](#ADInstanceDictionary) - Defines a passable dictionary of `ADRecord` values when encoding or decoding an Action Data class instance. Useful when creating your own custom Encoders and Decoders.
* [ADRecord](#ADRecord) - Defines a `ADRecord` as a dictionary of **Key/Value** pairs where the **Key** is a `String` and the **Value** is `Any` type.
* [ADRecordSet](#ADRecordSet) - Defines an array of `ADRecord` instances that can be sent to or returned from a `ADDataProvider` or any of the **Action Codable** controls.
* [ADSQLEncoder](#ADSQLEncoder) - Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSQLiteProvider`.
* [ADSQLDecoder](#ADSQLDecoder) - Decodes a `Codable` or `Decodable` class from a `ADRecord` read from a SQLite database using a `ADSQLiteProvider`.
* [ADSPONEncoder](#ADSPONEncoder) - Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSPONiteProvider`.
* [ADSPONDecoder](#ADSPONDecoder) - Decodes a `Codable` or `Decodable` class from a `ADRecord` read from a SQLite database using a `ADSPONiteProvider`.

<a name="ADInstanceArray"></a>
## ADInstanceArray

Defines a passable array of values used as temporary storage when encoding or decoding an Action Data class. `ADInstanceArray` also introduces support for the new **Swift Portable Object Notation** (SPON) data format that allows complex data models to be encoded in a portable text string that encodes not only property keys and data, but also includes type information about the encoded data. For example:
 
### Example:
```swift
let data = "@array[1!, 2!, 3!, 4!]"
let array = ADInstanceArray.decode(data)
```
 
The portable, human-readable string format encodes values with a single character _type designator_ as follows:
 
* `%` - Bool
* `!` - Int
* `$` - String
* `^` - Float
* `&` - Double
* `*` - Embedded `NSData` or `Data` value
 
Additionally, embedded arrays will be in the `@array[...]` format and embedded dictionaries in the `@obj:type<...>` format.

### Static Functions

* `escapeValue()` - Converts a given value into a format that can be safely stored in an ADInstanceArray portable, human-readable string format.
* `unescapeValue()` - Converts a value stored in portable, human-readable string format and converts it back to its original format.
* `decode()` - Takes a `ADInstanceArray` object stored in a portable, human-readable string format and converts it to an array of the original values. For example:

	```swift
	let data = "@array[1!, 2!, 3!, 4!]"
	let array = ADInstanceArray.decode(data)
	```

### Properties

* `subTableName` - Stores the name a sub `ADDataTable` used in a one-to-one foreign key relationship with the main table.
* `subTablePrimaryKey` - Stores the name of the primary key for a sub `ADDataTable` used in a one-to-one foreign key relationship with the main table.
* `subTablePrimaryKeyType` - Stores the primary key type for a sub `ADDataTable` used in a one-to-one foreign key relationship with the main table.
* `storage` - An array of values encoded from the object.

### Functions

* `encode()` - Converts the `ADInstanceArray` instance to a portable, human-readable string format.

<a name="ADInstanceDictionary"></a>
## ADInstanceDictionary

Defines a passable dictionary of `ADRecord` values when encoding or decoding an Action Data class instance. `ADInstanceDictionary` also introduces support for the new **Swift Portable Object Notation** (SPON) data format that allows complex data models to be encoded in a portable text string that encodes not only property keys and data, but also includes type information about the encoded data. For example:
 
### Example:
```swift
let data = "@obj:Rectangle<left!=`0` bottom!=`0` right!=`0` top!=`0`>"
let dictionary = ADInstanceDictionary.decode(data)
```
 
The portable, human-readable string format encodes values with a single character _type designator_ as follows:
 
* `%` - Bool
* `!` - Int
* `$` - String
* `^` - Float
* `&` - Double
* `*` - Embedded `NSData` or `Data` value
 
Additionally, embedded arrays will be in the `@array[...]` format and embedded dictionaries in the `@obj:type<...>` format.

### Static Functions

* `escapeValue()` - Converts a given value into a format that can be safely stored in an `ADInstanceDictionary` portable, human-readable string format.
* `unescapeValue()` - Converts a value stored in portable, human-readable string format and converts it back to its original format.
* `decode()` - Takes a `ADInstanceDictionary` object stored in a portable, human-readable string format and converts it to a dictionary of the original values. For example:

	```swift
	let data = "@obj:Rectangle<left!=`0` bottom!=`0` right!=`0` top!=`0`>"
	let dictionary = ADInstanceDictionary.decode(data)
	```
	
### Properties

* `subTableName` - Stores the name a sub `ADDataTable` used in a one-to-one foreign key relationship with the main table.
* `subTablePrimaryKey` - Stores the name of the primary key for a sub `ADDataTable` used in a one-to-one foreign key relationship with the main table.
* `subTablePrimaryKeyType` - Stores the primary key type for a sub ADDataTable used in a one-to-one foreign key relationship with the main table.
* `storage` - A dictionary of key/value pairs from the coded object.
* `typeName` - The name of the type of object being encoded in the dictionary. For example, this would be the name of a class.

### Functions

* `encode()` - Converts the ADInstanceDictionary instance to a portable, human-readable string format.

<a name="ADRecord"></a>
## ADRecord

Defines a `ADRecord` as a dictionary of **Key/Value** pairs where the **Key** is a `String` and the **Value** is `Any` type. A `ADRecord` can be returned from or sent to a `ADDataProvider` or any of the **Action Codable** controls.
 
### Example:
 
```swift
let provider = ADSQLiteProvider.shared
let record = try provider.query("SELECT * FROM Categories WHERE id = ?", withParameters: [1])
print(record["name"])
```

<a name="ADRecordSet"></a>
## ADRecordSet

Defines an array of `ADRecord` instances that can be sent to or returned from a `ADDataProvider` or any of the **Action Codable** controls.
 
### Example:

```swift
let provider = ADSQLiteProvider.shared
let records = try provider.getRows(Category.self)
 
for record in records {
 print(record["name"])
}
```

<a name=""></a>
## ADSQLEncoder

Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSQLiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Encodable`).
 
### Example:
```swift
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
	 var icon: Data = UIImage().toData()
	 
	 required init() {
	 
	 }
}
 
let encoder = ADSQLEncoder()
let category = Category()
let data = try encoder.encode(category)
```
 
###Remark: 

To store `UIColors` in the record use the `toHex()` extension method and to store `UIImages` use the `toData()` extension method.

### Enumerations

* `DateEncodingStrategy` - Defines the strategy to use for encoding `Date` values.
* `DataEncodingStrategy` - Defines the strategy to use for encoding `Data` values.

### Static Functions

* `iso8601Formatter` - Shared formatter used to encode a Date as an ISO-8601-formatted string (in RFC 3339 format).

### Properties

* `codingPath` - The path to the element currently being encoded.
* `userInfo` - User specific, additional information to be encoded in the output.
* `dateEncodingStrategy` - The strategy used to encode `Date` properties. The default is `rawDate` which allow the `ADSQLiteProvider` to handle the date directly.
* `dataEncodingStrategy` - The strategy used to encode `Data` or `NSData` properties. The default is `rawData` which allow the `ADSQLiteProvider` to handle the data directly.

### Initializers

* `init(dateEncodingStrategy:, dataEncodingStrategy:)` - Creates a new instance of the encoder and sets the default properties.

### Public Functions

* `encode()` - Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSQLiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle URLs and `Enums` (if the `Enum` is value based and also marked `Codable` or `Encodable`). For example:

	```swift
	// Sample encodable enum
	enum SwitchState: String, Codable {
		case on
		case off
	}
	
	// Encode `ADRecord` based class
	let object = MySQLRecordClass()
	let encoder = ADSQLEncoder()
	let record = encoder.encode(object)
	```
* `container(keyedBy:)` - Returns a key/value encoding container for the given key type.
* `unKeyedContainer()` - Returns an unkeyed encoding container.
* `singleValueContainer()` - Returns a single value encoding container.

<a name="ADSQLDecoder"></a>
## ADSQLDecoder

Decodes a `Codable` or `Decodable` class from a `ADRecord` read from a SQLite database using a `ADSQLiteProvider`. The result is an instance of the class with the properties set from the database record. This decoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Decodable`).
 
### Example:
```swift
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
	var icon: Data = UIImage().toData()
	 
	required init() {
	 
	}
}
 
let encoder = ADSQLEncoder()
let category = Category()
let data = try encoder.encode(category)
 
let decoder = ADSQLDecoder()
let category2 = try decoder.decode(Category.self, from: data)
```
 
### Remark: 
To retrieve `UIColors` in the record use the `String.uiColor` extension property and to retrieve `UIImages` use the `String.uiImage` extension property.

<a name=""></a>
## ADSPONEncoder

Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSPONiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Encodable`).

### Example:
```swift
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
	var icon: Data = UIImage().toData()
	
	required init() {
	
	}
}

let encoder = ADSPONEncoder()
let category = Category()
let data = try encoder.encode(category)
```

###Remark:

To store `UIColors` in the record use the `toHex()` extension method and to store `UIImages` use the `toData()` extension method.

### Enumerations

* `DateEncodingStrategy` - The strategy to use for encoding `Date` values.
* `DataEncodingStrategy` - The strategy to use for encoding `Data` values.

### Static Functions

* `iso8601Formatter` - Shared formatter used to encode a Date as an ISO-8601-formatted string (in RFC 3339 format).

### Properties

* `codingPath` - The path to the element currently being encoded.
* `userInfo` - User specific, additional information to be encoded in the output.
* `dateEncodingStrategy` - The strategy used to encode `Date` properties. The default is `rawDate` which allow the `ADSPONiteProvider` to handle the date directly.
* `dataEncodingStrategy` - The strategy used to encode `Data` or NSData properties. The default is rawData which allow the ADSPONiteProvider to handle the data directly.

### Initializers

* `init(dateEncodingStrategy:dataEncodingStrategy)` - Creates a new instance of the encoder and sets its initial properties.

### Public Functions

* `encode()` - Encodes a Codable or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSPONiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle URLs and `Enums` (if the `Enum` is value based and also marked `Codable` or `Encodable`). For example:

	```swift
	// Sample encodable enum
	enum SwitchState: String, Codable {
	    case on
	    case off
	}
	
	// Example of encoding a class
	let object = MySQLRecordClass()
	let encoder = ADSPONEncoder()
	let record = encoder.encode(object)
	```
* `container(keyedBy:)` - Returns a key/value encoding container for the given key type.
* `unkeyedContainer()` - Returns an unkeyed encoding container.
* `singleValueContainer()` - Returns a single value encoding container.

<a name="ADSPONDecoder"></a>
## ADSPONDecoder

Decodes a `Codable` or `Decodable` class from a `ADRecord` read from a SQLite database using a `ADSPONiteProvider`. The result is an instance of the class with the properties set from the database record. This decoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Decodable`).

### Example:
```swift
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
	var icon: Data = UIImage().toData()
	
	required init() {
	
	}
}

let encoder = ADSPONEncoder()
let category = Category()
let data = try encoder.encode(category)

let decoder = ADSPONDecoder()
let category2 = try decoder.decode(Category.self, from: data)
```

### Remark:
To retrieve `UIColors` in the record use the `String.uiColor` extension property and to retrieve `UIImages` use the `String.uiImage` extension property.

### Enumerations

* `DateDecodingStrategy` - The strategy to use for encoding `Date` values.
* `DataDecodingStrategy` - The strategy to use for encoding `Data` values.

### Static Functions

* `sqlObject()` - Checks to see if a `sqlObject` is stored in the given data stream and returns it if it is.
* `iso8601Formatter` - Shared formatter used to encode a `Date` as an ISO-8601-formatted string (in RFC 3339 format).

### Properties

* `codingPath` - The path to the current value that is being decoded.
* `userInfo` - User specific information that can be used when decoding an item.
* `dateDecodingStrategy` - The strategy used to decode `Date` properties. The default is `rawDate` which allow the `ADSPONiteProvider` to handle the date directly.
* `dataDecodingStrategy` - The strategy used to encode `Data` or `NSData` properties. The default is rawData which allow the `ADSPONiteProvider` to handle the data directly.

### Initializers

* `init(dateDecodingStrategy:dataDecodingStrategy)` - Creates a new instance of the decoder.

### Public Functions

* `decode()` - Decodes a `Codable` or `Decodable` class from a `ADRecord` read from a SQLite database using a `ADSPONiteProvider`. The result is an instance of the class with the properties set from the database record. This decoder will automatically handle URLs and Enums (if the `Enum` is value based and also marked `Codable` or `Decodable`). For example:

	```swift
	// Sample codable enum
	enum SwitchState: String, Codable {
		case on
		case off
	}
	
	// Example of decoding an object
	let record = ADSPONiteProvider.shared.query("SELECT * FROM TASKS WHERE ID=1")
	let decoder = ADSPONDecoder()
	let task = decoder.decode(Task, from: record)
	```
* `container(keyedBy:)` - Returns the keyed decoding container for the given key type.
* `unkeyedContainer()` - Returns an unkeyed decoding container.
* `singleValueContainer()` - Returns a single value decoding container.