# Action SQL Parser Quick Start

**Action SQL Parser** provides an Action Data SQL Document Object Model (DOM) that can store and process commands in the SQL syntax (specifically a subset of the SQLite syntax). Using the elements of the **Action SQL Parser** you can add SQL language support to data sources that typically don't understand SQL, such as JSON or CloudKit.

The following topics will be discussed in detail:

* [Parsing SQL Instructions](#Parsing-SQL-Instructions)
* [Implementing SQL Support](#Implementing-SQL-Support)

The following **Shared Elements** are available:

* [ADSQLParseQueue](#ADSQLParseQueue)
* [ADSQLColumnDefinition](#ADSQLColumnDefinition)
* [ADSQLColumnConstraint](#ADSQLColumnConstraint)
* [ADSQLTableConstraint](#ADSQLTableConstraint)
* [ADSQLResultColumn](#ADSQLResultColumn)
* [ADSQLJoinClause](#ADSQLJoinClause)
* [ADSQLOrderByClause](#ADSQLOrderByClause)
* [ADSQLSetClause](#ADSQLSetClause)

The following **Instructions** are available:

* [ADSQLAlterTableInstruction](#ADSQLAlterTableInstruction)
* [ADSQLCreateIndexInstruction](#ADSQLCreateIndexInstruction)
* [ADSQLCreateTableInstruction](#ADSQLCreateTableInstruction)
* [ADSQLCreateTriggerInstruction](#ADSQLCreateTriggerInstruction)
* [ADSQLCreateViewInstruction](#ADSQLCreateViewInstruction)
* [ADSQLSelectInstruction](#ADSQLSelectInstruction)
* [ADSQLInsertInstruction](#ADSQLInsertInstruction)
* [ADSQLUpdateInstruction](#ADSQLUpdateInstruction)
* [ADSQLDeleteInstruction](#ADSQLDeleteInstruction)
* [ADSQLDropInstruction](#ADSQLDropInstruction)
* [ADSQLTransactionInstruction](#ADSQLTransactionInstruction)


The following **Expressions** are available:

* [ADSQLLiteralExpression](#ADSQLLiteralExpression)
* [ADSQLUnaryExpression](#ADSQLUnaryExpression)
* [ADSQLBinaryExpression](#ADSQLBinaryExpression)
* [ADSQLFunctionExpression](#ADSQLFunctionExpression)
* [ADSQLBetweenExpression](#ADSQLBetweenExpression)
* [ADSQLInExpression](#ADSQLInExpression)
* [ADSQLWhenExpression](#ADSQLWhenExpression)
* [ADSQLCaseExpression](#ADSQLCaseExpression)
* [ADSQLForeignKeyExpression](#ADSQLForeignKeyExpression)

The following shared **Enumerations** are available:

* [ADSQLKeyword](#ADSQLKeyword)
* [ADSQLFunction](#ADSQLFunction)
* [ADSQLColumnType](#ADSQLColumnType)
* [ADSQLParseError](#ADSQLParseError)
* [ADSQLConflictHandling](#ADSQLConflictHandling)

<a name="Parsing-SQL-Instructions"></a>
## Parsing SQL Instructions

Use the `ADSQLParser` class to parse text in the SQL language format into a collection of Action Data SQL Document Object Model (DOM) objects. For example:

```swift
let sql = """
CREATE TABLE IF NOT EXISTS parts
(
 part_id           INTEGER   PRIMARY KEY,
 stock             INTEGER   DEFAULT 0   NOT NULL,
 description       TEXT      CHECK( description != '' )    -- empty strings not allowed
);
"""
 
let instructions = try ADSQLParser.parse(sql)
print(instructions)
```

Will return a collection of objects conforming to the `ADSQLInstruction` protocol. For example, the above code would return a `ADSQLCreateTableInstruction` that holds a collection of `ADSQLColumnDefinitions` that in turn holds a collection of `ADSQLColumnConstraints` that could be used to build a new table in a given data source (JSON, XML, CloudKit, etc.)

Take a look at an example of selecting a record:

```swift
let sql = "SELECT * FROM Parts WHERE part_id = 100"
 
let instructions = try ADSQLParser.parse(sql)
print(instructions)
```

Again, the above code will return a collection of objects conforming to the `ADSQLInstruction` protocol. The top most item will be a `ADSQLSelectInstruction` that includes a collection of `ADSQLResultColumn` objects and a collection of `ADSQLExpression` objects that could be used to retrieve a record from a given data source (JSON, XML, CloudKit, etc.)

<a name="Implementing-SQL-Support"></a>
## Implementing SQL Support

When you use the `ADSQLParser` `parse` command you are given back either a collection of objects representing a Action Data SQL Document Object Model (DOM) or a `ADSQLParseError` is thrown.

It is up to the developer to take the Action Data SQL Document Object Model (DOM) and apply it to the data source to achieve the desired goal.

For example, here is the instruction handler for the `execute` function of the `ADDataStore` class:

```swift
public func execute(_ sql: String, parameters: [Any] = []) throws {
    let command = (parameters.count == 0) ? sql : try prepareSQL(sql, parameters: parameters)
    let instructions = try ADSQLParser.parse(command)
    
    // Process all instructions
    for instruction in instructions {
        // Take action based on the instruction type
        if let command = instruction as? ADSQLCreateTableInstruction {
            try createTable(command)
        } else if let command = instruction as? ADSQLAlterTableInstruction {
            try alterTable(command)
        } else if instruction is ADSQLCreateIndexInstruction {
            throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support creating indexes.")
        } else if instruction is ADSQLCreateTriggerInstruction {
            throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support creating triggers")
        } else if instruction is ADSQLCreateViewInstruction {
            throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support creating views")
        } else if instruction is ADSQLSelectInstruction {
            throw ADSQLExecutionError.unsupportedCommand(message: "SELECT command is invalid in `execute`, call `query` instead.")
        } else if let command = instruction as? ADSQLDropInstruction {
            try drop(command)
        } else if let command = instruction as? ADSQLInsertInstruction {
            tableLastInsertedInto = command.tableName
            try insert(command)
        } else if let command = instruction as? ADSQLTransactionInstruction {
            // Take action based on the action type
            switch command.action {
            case .beginDeferred, .beginExclusive, .beginImmediate:
                beginTransaction()
            case .commit:
                commitTransaction()
            case .rollback:
                rollbackTransaction()
            case .savepoint, .releaseSavepoint:
                throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support creating named savepoint transactions.")
            }
        } else if let command = instruction as? ADSQLUpdateInstruction {
            try update(command)
        } else if let command = instruction as? ADSQLDeleteInstruction {
            try delete(command)
        } else {
            throw ADSQLExecutionError.invalidCommand(message: "Instruction `\(instruction)` not valid in an EXECUTE call.")
        }
    }
}
```

Notice how it uses the `ADSQLParser.parse` to create a collection of instructions, then it loops over those instructions and applies them to the data source based on their type.

Similarly, the `query` function uses the same technique:

```swift
public func query(_ sql: String, parameters: [Any] = []) throws -> ADRecordSet {
    var records: ADRecordSet = []
    let command = (parameters.count == 0) ? sql : try prepareSQL(sql, parameters: parameters)
    let instructions = try ADSQLParser.parse(command)
    
    // Process all instructions
    for instruction in instructions {
        if let command = instruction as? ADSQLSelectInstruction {
            records = try select(command)
        } else {
            throw ADSQLExecutionError.invalidCommand(message: "Instruction `\(instruction)` not valid in a QUERY call.")
        }
    }
    
    // Return results
    return records
}
```  

Based on the type of data source you are working with, you might simply need to translate SQL instructions to base instruction of that source. For example, you could translate the SQL Create Table instruction into a CloudKit Create Table instruction then run that against CloudKit.

For other types of data sources, you will need to implement support yourself. Take the example of the `createTable` function of the `ADDataStore` class:

```swift
private func createTable(_ instruction: ADSQLCreateTableInstruction) throws {
        
    // Is the table already on file?
    if hasTable(named: instruction.name) {
        if instruction.ifNotExists {
            return
        } else {
            throw ADSQLExecutionError.duplicateTable(message: "Table `\(instruction.name)` already exists in the data store.")
        }
    }
    
    // Build table storage
    let table = ADTableStore(tableName: instruction.name)
    
    // Populate the table schema
    var id = 0
    for column in instruction.columns {
        // Build a schema for this column
        let columnDef = ADColumnSchema(id: id, name: column.name, type: column.type)
        
        // Populate any constraints
        for constraint in column.constraints {
            // Take action based on the constraint type
            switch constraint.type {
            case .primaryKeyAsc, .primaryKeyDesc:
                columnDef.isPrimaryKey = true
                columnDef.autoIncrement = constraint.autoIncrement
            case .notNull:
                columnDef.allowsNull = false
            case .unique:
                columnDef.isKeyUnique = true
            case .check:
                columnDef.checkExpression = constraint.expression
            case .defaultValue:
                columnDef.defaultValue = try constraint.expression?.evaluate(forRecord: nil)
            case .collate:
                throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support collate constraints on table columns.")
            case .foreignKey:
                throw ADSQLExecutionError.unsupportedCommand(message: "ADDataStore does not support foreign key constraints on table columns.")
            }
        }
        
        // Save column and increment ID
        table.schema.add(value: columnDef)
        id += 1
    }
    
    // Create from a select statement?
    if let selectStatement = instruction.selectStatement {
        let rows = try select(selectStatement)
        if rows.count > 0 {
            let row = rows[0]
            var id = 0
            for key in row.keys {
                if !table.schema.hasColumn(named: key) {
                    // Build a schema for this column
                    let columnDef = ADColumnSchema(id: id, name: key, type: .noneType)
                    
                    // Save column and increment ID
                    table.schema.add(value: columnDef)
                    id += 1
                }
            }
            
            // Copy over data
            table.rows = rows
        } else {
            throw ADSQLExecutionError.noRowsReturned(message: "The SELECT clause used to create table `\(instruction.name)` returned no rows.")
        }
    }
    
    // Add table to data store
    tables[instruction.name] = table
}
```

#  Shared Elements

Contains elements shared across all **SQL Parser** DOM items such as `ADSQLColumnConstraint` and `ADSQLOrderByClause`.

<a name="ADSQLParseQueue"></a>
## ADSQLParseQueue

Parses the raw SQL command text into a queue of decomposed substrings based on defined set of SQL language rules. A `ADSQLParseQueue` is called as the first stage of parsing a given set of one or more SQL commands. 

The `ADSQLParseQueue` provides the following:

* **shared** - A shared instance of the `ADSQLParseQueue` that can be called across object instances.
* **queue** - The queue of parsed substrings.
* **count** - The number of substrings in the queue.
* **push** - Pushes a new substring onto the queue.
* **replaceLastElement** - Replaces the last substring pushed into the queue with the given substring.
* **removeLastElement** - Removes the last substring pushed into the queue.
* **pop** - Removes the first substring from the queue.
* **lookAhead** - Returns the first substring from the queue without removing it.
* **parse** - Takes a string containing valid SQL commands and converts it into a queue of decomposed substrings based on defined set of SQL language rules.

<a name="ADSQLColumnDefinition"></a>
## ADSQLColumnDefinition

Holds information about a column definition read from a **CREATE TABLE** instruction when parsing a SQL statement.

This includes the following information:

* **name** - The column name.
* **alias** - The optional column alias.
* **type** - The type of information stored in the column as defined by a `ADSQLColumnType`.
* **constraints** - A list of optional constraints for the column.

<a name="ADSQLColumnConstraint"></a>
## ADSQLColumnConstraint

Holds information about a constraint applied to a Column Definition that has been parsed from a SQL **CREATE TABLE** instruction.

Defines the `ColumnConstraintType` enumeration as:

* **primaryKeyAsc** - The column is the primary key for the table in an ascending order.
* **primaryKeyDesc** - The column is the primary key for the table in a descending order.
* **notNull** - The column's value cannot be NULL.
* **unique** - The column's value must be unique inside the table.
* **check** - A custom constraint is being applied to the columns value.
* **defaultValue** - If this column is NULL, it will be replaced with this default value.
* **collate** - The column has a collation constraint.
* **foreignKey** - The column value is a foreign key to another table's row.

This includes the following information:

* **type** - The type of the constraint.
* **autoIncrement** - If the column is a PRIMARY KEY of the INTEGER type, is it automatically incremented when a new row is created in the table.
* **conflictHandling** - Defines how conflicts should be handled for this column.
* **expression** - Holds the expression for a Check or Default Value constraint.

<a name="ADSQLTableConstraint"></a>
## ADSQLTableConstraint

Holds information about a constraint being applied to table from a **CREATE TABLE** SQL instruction.

Defines the `TableConstraintType` enumeration as:

* **primaryKey** - A `PrimaryKey(...)` constraint.
* **unique** - A unique value constraint.
* **check** - A custom constraint.
* **foreignKey** - A value in the table that is a key to a row in a foreign table.

This includes the following information:

* **type** - The type of the table constraint.
* **conflictHandling** - The type of conflict handling for this table constraint.
* **expression** - The value for a Check constraint.
* **columnList** - A list of columns that this constraint effects.

<a name="ADSQLResultColumn"></a>
## ADSQLResultColumn

Holds a result column definition for a **SELECT** SQL statement.

This includes the following information:

* **expression** - The value of the column as either a calculated expression or a literal column name.
* **columnAlias** - An optional alias for the column value returned.

<a name="ADSQLJoinClause"></a>
## ADSQLJoinClause

Holds the source table or table group for a SQL **SELECT** statement's **FROM** clause. If the `type` is `none` this is a single table name and not a join between two (or more) tables.

Defines the `JoinType` enumeration as:

* **none** - This join represents an individual table name.
* **natural** - The table is joined to another table where on any fields that have the same name and value.
* **leftOuter** - This table is Left Outer Joined to another table.
* **inner** - This table is Inner Joined to another table.
* **cross** - This table is Cross Joined to another table.

This includes the following information:

* **parentTable** - The name of the parent table in a join operation or a literal table name is no join is being performed and the `type` property's value is `none`.
* **parentTableAlias** - The optional alias for the parent table.
* **childTable** - The name of the child table in a join operation of empty string if no join is being performed.
* **childTableAlias** - The alias for the child table.
* **childJoin** - If the child table is part of a join, this represents its join clause.
* **type** - The type of join being performed.
* **onExpression** - Defines the conditions that two tables are joined on or `nil` if no join is being performed.
* **columnList** - A list of columns that are part of the join.

<a name="ADSQLOrderByClause"></a>
## ADSQLOrderByClause

Holds information about a result ordering statement from a SQL **SELECT** statement.

Defines the `Order` enumeration as:

* **ascending** - Sort values in ascending order.
* **descending** - Sort values in a descending order.

This includes the following information:

* **columnName** - The name of the column used to order the results.
* **collationName** - The optional collation name.
* **order** - The sort or for the results.

<a name="ADSQLSetClause"></a>
## ADSQLSetClause

Holds information about a value that is being written into a table's column from a SQL **UPDATE** statement.

This includes the following information:

* **columnName** - The name of the column getting the new value.
* **expression** - The value being written to the  column.

#  Instructions

Contains the **Object Models** used to hold the individual SQL commands parsed from the original text stream using a `ADSQLParser` such as `ADSQLCreateTableInstruction` and `ADSQLSelectInstruction`.

<a name="ADSQLAlterTableInstruction"></a>
## ADSQLAlterTableInstruction

Holds the information for a SQL **ALTER TABLE** instruction.

This includes the following information:

* **name** - The name of the table being modified.
* **renameTo** - If renaming the table, this will be the table's new name.
* **column** - The definition of a columns being added.

<a name="ADSQLCreateIndexInstruction"></a>
## ADSQLCreateIndexInstruction

Holds the information for a SQL **CREATE INDEX** instruction.

This includes the following information:

* **makeUnique** - If `true` the index is unique, else `false`.
* **indexName** - The name of the index being created.
* **tableName** - The name of the table that the index is being created on.
* **columnList** - The list of columns in the index.
* **whereExpression** - The optional WHERE clause that controls which table rows are included in the Index.

<a name="ADSQLCreateTableInstruction"></a>
## ADSQLCreateTableInstruction

Holds information about a SQL **CREATE TABLE** instruction.

This includes the following information:

* **name** - The name of the table being created.
* **isTemporary** - If `true` this is a temporary table, else `false`.
* **ifNotExists** - If `true` the table should only be created if it doesn't already exist, else `false`.
* **columns** - A list of columns being created in the table.
* **constraints** - An optional list of constraints being applied to the table.
* **withoutRowID** - If `true` the table does not have an internal row id, else `false`.
* **selectStatement** - If this is a CREATE TABLE name AS SELECT... statement, this property holds the SELECT statement.

<a name="ADSQLCreateTriggerInstruction"></a>
## ADSQLCreateTriggerInstruction

Holds information about a SQL **CREATE TRIGGER** instruction.

Defines the `WhenToTrigger` enumeration as:

* **before** - The trigger will execute before the SQL statement.
* **after** - The trigger will execute after the SQL statement.
* **insteadOf** - The trigger will execute instead of the SQL statement.

Defines the `TriggerType` enumeration as:

* **delete** - The trigger will fire on delete statements.
* **insert** - The trigger will fire on insert statements.
* **updateOf** - The trigger will fire on update statements.

This includes the following information:

* **triggerName** - The name of the trigger being created.
* **triggerWhen** - Defines when the trigger should fire.
* **triggerType** - Defines the type of trigger being created.
* **columnList** - Defines the list of columns that form the trigger.
* **tableName** - Defines the table that the trigger is being created against.
* **forEachRow** - If `true`, the trigger will execute after each table row being modified by a SQL statement.
* **whenExpression** - The expression defining when the trigger will fire.
* **instructions** - A list of instruction to run when the trigger fires.


<a name="ADSQLCreateViewInstruction"></a>
## ADSQLCreateViewInstruction

Holds all the information for a SQL **CREATE VIEW** instruction.

This includes the following information:

* **viewName** - The name of the view being created.
* **columnList** - The list of columns in the view.
* **selectStatement** - The SQL SELECT statement used to populate the view.

<a name="ADSQLSelectInstruction"></a>
## ADSQLSelectInstruction

Holds all information about a SQL **SELECT** instruction.

This includes the following information:

* **distinct** - If `true`, a distinct set of values will be returned, else `false`.
* **columns** - The list of columns returned by this select statement.
* **fromSource** - The source table (or tables) that the columns are read from.
* **whereExpression** - The WHERE clause defining which table rows should be returned. If this expression if `nil`, all rows will be returned.
* **groupByColumns** - An optional GROUP BY clause used to group the results of the SELECT statement.
* **havingExpression** - An optional HAVING clause to control when specific columns should be grouped.
* **orderBy** - An optional group of columns used to sort the resulting table rows.
* **limit** - Defines the maximum number of rows returned. If `-1`, all rows will be returned.
* **offset** - Defines an offset from the first row to start returning rows for. If `-1`, the results start with the first row.

<a name="ADSQLInsertInstruction"></a>
## ADSQLInsertInstruction

Holds all information about a SQL **INSERT** instruction.

Defines the `Action` enumeration as:

* **insert** - Attempt to insert a new row.
* **replace** - Attempt to replace an existing row.
* **insertOrReplace** - Either insert a new or replace an existing row.
* **insertOrRollback** - Attempt to insert a new row and rollback if the row cannot be created.
* **insertOrAbort** - Attempt to insert a new row and abort if the row cannot be created.
* **insertOrFail** - Attempt to insert a new row and fail if the row cannot be created.
* **insertOrIgnore** - Attempt to insert a new row and ignore the issue if the row cannot be created.

This includes the following information:

* **action** - The type of insert to perform.
* **tableName** - The name of the table that a row is being inserted into.
* **columnName** - The name of the columns being inserted into the table row.
* **values** - The values to insert into the table row.
* **selectStatement** - An optional SELECT statement used to populate the new table row(s).
* **defaultValues** - If `true`, the new row should be created with the default value of the table.

<a name="ADSQLUpdateInstruction"></a>
## ADSQLUpdateInstruction

Holds all of the information for a SQL **UPDATE** instruction.

Defines the `Action` enumeration as:

* **update** - Attempt to update a row in the table.
* **updateOrRollback** - Attempt to update a row in the table and rollback if unable to update.
* **updateOrAbort** - Attempt to update a row in the table and abort if unable to update.
* **updateOrReplace** - Attempt to update or replace a row in the table.
* **updateOrFail** - Attempt to update a row in the table and fail if unable to update.
* **updateOrIgnore** - Attempt to update a row in the table and ignore the issue if unable to update.

This includes the following information:

* **action** - The type of update to perform.
* **tableName** - The name of the table being updated.
* **setClause** - A list of columns and values being written to the row.
* **whereClause** - An optional expression controlling the rows to update.

<a name="ADSQLDeleteInstruction"></a>
## ADSQLDeleteInstruction

Holds all information about a SQL **DELETE** instruction.

This includes the following information:

* **tableName** - The name of the table that rows will be deleted from.
* **whereExpression** - An optional WHERE clause used to determine the rows of the table to delete. If `nil` all rows in the table will be deleted.

<a name="ADSQLDropInstruction"></a>
## ADSQLDropInstruction

Holds all information about a SQL **DROP** instruction.

Defines the `Action` enumeration as:

* **index** - Drops an index.
* **table** - Drops a table.
* **trigger** - Drops a trigger.
* **view** - Drops a view.

This includes the following information:

* **action** - Defines what is being removed from the data source.
* **ifExists** - If `true`, the item will only be dropped if it exists in the data source.
* **itemName** - The name of the item being removed from the data source.

<a name="ADSQLTransactionInstruction"></a>
## ADSQLTransactionInstruction

Holds all information about a SQL **BEGIN**, **COMMIT**, **END**, **ROLLBACK**, **SAVEPOINT** or **RELEASE** instruction.

Defines the `Action` enumeration as:

* **beginDeferred** - A begin deferred transaction.
* **beginImmediate** - A begin immediate transaction.
* **beginExclusive** - A begin exclusive transaction.
* **commit** - A commit (or end) transaction.
* **rollback** - A rollback transaction.
* **savepoint** -  create save point transaction.
* **releaseSavepoint** - A release save point transaction.

This includes the following information:

* **action** - Defined the type of transaction.
* **savepointName** - For ROLLBACK, SAVEPOINT and RELEASE transactions, defines the name of the save point.

#  Expressions

Contains the **Object Models** used to hold the individual expressions parsed from a SQL command by a `ADSQLParser`. Expressions represent items such as the result columns for SQL **SELECT** commands, the comparisons in a **WHERE** clause or elements from a **ORDER BY** clause.

Expressions conform to the `ADSQLExpression` protocol and all include the following functions:

* **init(fromInstance dictionary: ADInstanceDictionary)** 

	Decodes the expression from an Instance Dictionary that has been read from a Swift Portable Object Notation (SPON) stream.
	
	- **Parameter** dictionary: A `ADInstanceDictionary` representing the values for the expression.

* **@discardableResult func evaluate(forRecord record: ADRecord?) throws -> Any?**

	Evaluates the given expression and returns a result based on the data in the record passed in.

	- **Parameter** record: A `ADRecord` containing values to be evaluated against the expression.
	- **Returns**: The result of the evaluation.

* **encode() -> ADInstanceDictionary**

	Encodes the expression into an Instance Dictionary for storage in a Swift Portable Object Notation (SPON) format.
	
     -**Returns**: The expression represented as an Instance Dictionary.

* **decode(fromInstance dictionary: ADInstanceDictionary)**

	Decodes the expression from an Instance Dictionary that has been read from a Swift Portable Object Notation (SPON) stream.
	
     - **Parameter** dictionary: A `ADInstanceDictionary` representing the values for the expression.

<a name="ADSQLLiteralExpression"></a>
## ADSQLLiteralExpression

Defines a literal expression used in a SQL instruction such as a column name, integer value or string constant value.

This includes the following information:

* **value** - Defines the value of the literal.

<a name="ADSQLUnaryExpression"></a>
## ADSQLUnaryExpression

Defines a unary expression used in a SQL instruction such as forcing a value to be positive or negative.

Defines the `UnaryOperation` enumeration as:

* **positive** - Force a value to be positive.
* **negative** - Force a value to be negative.
* **not** - Negate a boolean value.
* **group** - Group a value.

This includes the following information:

* **operation** - The type of unary operation to perform.
* **value** - The value that is being operated on.


<a name="ADSQLBinaryExpression"></a>
## ADSQLBinaryExpression

Defines a binary operation being performed on two expressions in a SQL instruction such as adding two values or comparing two values to see if they are equal.

Defines the `BinaryOperation` enumeration as:

* **addition** - Adding two values.
* **subtraction** - Subtracting one value from another.
* **multiplication** - Multiplying two values.
* **division** - Dividing a value by another.
* **equalTo** - Testing to see if two values are equal.
* **notEqualTo** - Testing to see if two values are not equal.
* **lessThan** - Testing to see if one value is less than another.
* **greaterThan** - Testing to see if one value is greater than another.
* **lessThanOrEqualTo** - Testing to see if one value is less than or equal to another.
* **greaterThanOrEqualTo** - Testing to see if one value is greater than or equal to another.
* **and** - Testing to see if both values are `true`.
* **or** - Testing to see if either value is `true`.
* **castTo** - Casting a value to another type.
* **collate** - Perform a collations on both values.
* **like** - See if one value is like another.
* **glob** - See if one value is like another.
* **regexp** - Perform a RegEx operation on a value.
* **match** - See if one value matches another.

This includes the following information:

* **leftValue** - The left side of the binary expression.
* **operation** - The operation to perform on both values.
* **rightValue** - The right side of the binary expression.

<a name="ADSQLFunctionExpression"></a>
## ADSQLFunctionExpression

Defines a function being called in a SQL instruction such as `count` or `sum`.

This includes the following information:

* **functionType** - The type of function being performed.
* **parameters** - The list of optional parameters being passed to the function.
* **isAggregate** - Returns `true` if the function is one of the aggregate functions: COUNT, MIN, MAX, AVG, SUM.

<a name="ADSQLBetweenExpression"></a>
## ADSQLBetweenExpression

Defines a between expression used in a SQL instruction to test if a value is between two other values.

This includes the following information:

* **value** - The value to test.
* **lowValue** - The low range to test against.
* **highValue** - The high range to test against.
* **negate** - If `true`, negate the results of the test, else `false`.

<a name="ADSQLInExpression"></a>
## ADSQLInExpression

Defines a in expression used in a SQL instruction to see if a value is in the list of give values.

This includes the following information:

* **value** - The value to test.
* **list** - The list of possible values.
* **negate** - If `true`, negate the results of the test, else `false`.

<a name="ADSQLWhenExpression"></a>
## ADSQLWhenExpression

Defines a when clause using in a **CASE** clause in a SQL instruction.

This includes the following information:

* **whenValue** - The value used to trigger the expression.
* **thenValue** - The value returned when triggered.

<a name="ADSQLCaseExpression"></a>
## ADSQLCaseExpression

Defines a case clause used in a SQL instruction.

This includes the following information:

* **compareValue** - The value to compare.
* **toValues** - The list of value to compare against.
* **defaultValue** - he default value to return when no values match.

<a name="ADSQLForeignKeyExpression"></a>
## ADSQLForeignKeyExpression

Defines a foreign key expression used in a SQL statement.

Defines the `OnModify` enumeration as:

* **ignore** - Ignore the key if modified.
* **delete** - Delete the foreign value if deleting a row with the key.
* **update** - Update the foreign value if update a row with the key.

Defines the `ModifyAction` enumeration as:

* **setNull** - Set the key to null.
* **setDefault** - Set the key to the default value.
* **cascade** - Cascade changes to the foreign key's table.
* **restrict** - Restrict changes to the foreign key.
* **noAction** - Take no action.

This includes the following information:

* **foreignTableName** - The name of the foreign key table.
* **columnNames** - A list of columns that compose the key.
* **onModify** - The action to take when the foreign key is modified when the parent row is modified.
* **modifyAction** - The action to take when modifying a foreign key value.
* **matchName** - The name of the field to match in the foreign key table.
* **deferrable** - If `true`, the action is deferrable, else `false`.
* **initiallyImmediate** - If `true`, the action is immediate, else `false`.

#  Enumerations

Contains the Enumerations used throughout the **SQL Parser** system to define things such as SQL Keywords, Function Names, Column Data Types and Parser Error Codes.

<a name="ADSQLKeyword"></a>
## ADSQLKeyword

Contains a list of all valid SQL keywords that the `ADSQLParser` can understand:

* abortKey = "ABORT"
* actionKey = "ACTION"
* addKey = "ADD"
* afterKey = "AFTER"
* allKey = "ALL"
* alterKey = "ALTER"
* analyzeKey = "ANALYZE"
* andKey = "AND"
* asKey = "AS"
* ascKey = "ASC"
* attachKey = "ATTACH"
* autoIncrementKey = "AUTOINCREMENT"
* beforeKey = "BEFORE"
* beginKey = "BEGIN"
* betweenKey = "BETWEEN"
* byKey = "BY"
* cascadeKey = "CASCADE"
* caseKey = "CASE"
* castKey = "CAST"
* checkKey = "CHECK"
* collateKey = "COLLATE"
* columnKey = "COLUMN"
* commitKey = "COMMIT"
* conflictKey = "COMFLICT"
* constraintKey = "CONSTRAINT"
* createKey = "CREATE"
* crossKey = "CROSS"
* currentDateKey = "CURRENT_DATE"
* currentTimeKey = "CURRENT_TIME"
* currentTimestampKey = "CURRENT_TIMESTAMP"
* databaseKey = "DATABASE"
* defaultKey = "DEFAULT"
* deferrableKey = "DEFERRABLE"
* deferredKey = "DEFERRED"
* deleteKey = "DELETE"
* descKey = "DESC"
* detachKey = "DETACH"
* distinctKey = "DISTINCT"
* dropKey = "DROP"
* eachKey = "EACH"
* elseKey = "ELSE"
* endKey = "END"
* escapeKey = "ESCAPE"
* exceptKey = "EXCEPT"
* exclusiveKey = "EXCLUSIVE"
* existsKey = "EXISTS"
* explainKey = "EXPLAIN"
* failKey = "FAIL"
* forKey = "FOR"
* foreignKey = "FOREIGN"
* fromKey = "FROM"
* fullKey = "FULL"
* globKey = "GLOB"
* groupKey = "GROUP"
* havingKey = "HAVING"
* ifKey = "IF"
* ignoreKey = "IGNORE"
* immediateKey = "IMMEDIATE"
* inKey = "IN"
* indexKey = "INDEX"
* indexedKey = "INDEXED"
* initiallyKey = "INITIALLY"
* innerKey = "INNER"
* insertKey = "INSERT"
* insteadKey = "INSTEAD"
* intersectKey = "INTERSECT"
* intoKey = "INTO"
* isKey = "IS"
* isNullKey = "ISNULL"
* joinKey = "JOIN"
* keyKey = "KEY"
* leftKey = "LEFT"
* likeKey = "LIKE"
* limitKey = "LIMIT"
* matchKey = "MATCH"
* naturalKey = "NATURAL"
* noKey = "NO"
* notKey = "NOT"
* notNullKey = "NOTNULL"
* nullKey = "NULL"
* ofKey = "OF"
* offsetKey = "OFFSET"
* onKey = "ON"
* orKey = "OR"
* orderKey = "ORDER"
* outerKey = "OUTER"
* planKey = "PLAN"
* pragmaKey = "PRAGMA"
* primaryKey = "PRIMARY"
* queryKey = "QUERY"
* raiseKey = "RAISE"
* recursiveKey = "RECURSIVE"
* referencesKey = "REFERENCES"
* regexpKey = "REGEXP"
* reindexKey = "REINDEX"
* releaseKey = "RELEASE"
* renameKey = "RENAME"
* replaceKey = "REPLACE"
* restrictKey = "RESTRICT"
* rightKey = "RIGHT"
* rollbackKey = "ROLLBACK"
* rowKey = "ROW"
* rowIDKey = "ROWID"
* savePointKey = "SAVEPOINT"
* selectKey = "SELECT"
* setKey = "SET"
* tableKey = "TABLE"
* tempKey = "TEMP"
* temporaryKey = "TEMPORARY"
* thenKey = "THEN"
* toKey = "TO"
* transactionKey = "TRANSACTION"
* triggerKey = "TRIGGER"
* unionKey = "UNION"
* uniqueKey = "UNIQUE"
* updateKey = "UPDATE"
* usingKey = "USING"
* vacuumKey = "VACUUM"
* valuesKey = "VALUES"
* viewKey = "VIEW"
* virtualKey = "VIRTUAL"
* whenKey = "WHEN"
* whereKey = "WHERE"
* withKey = "WITH"
* withoutKey = "WITHOUT"
* emptyStringKey = "EMPTY_STRING"
* semicolon = ";"
* openParenthesis = "("
* closedParenthesis = ")"
* comma = ","
* equal = "="
* notEqual = "!="
* lessThan = "<"
* greaterThan = ">"
* lessThanOrEqualTo = "<="
* greaterThanOrEqualTo = ">="
* plus = "+"
* minus = "-"
* asterisk = "*"
* forwardSlash = "/"

The `get` static method attempts to convert the given string value into a `SQLKeyword` and ignores case. For example:

```swift
let key = ADSQLKeyword.get("select")
```

<a name="ADSQLFunction"></a>
## ADSQLFunction

Defines the type of functions that can be called in a SQL expression:

* **ltrim = "ltrim"** - Trims any white spaces off of the left side of a string.
* **trim = "trim"** - Trims any white spaces off both sides of a string.
* **instr = "instr"** - Tests to see if one string contains another.
* **replace = "replace"** - Replaces all instances of one string inside another.
* **upper = "upper"** - Converts the string to upper case.
* **length = "length"** - Returns the length of the string in characters.
* **rtrim = "rtrim"** - Trims any white spaces off of the right side of the string.
* **lower = "lower"** - Converts the string to lower case.
* **substr = "substr"** - Returns the requested portion of the string.
* **abs = "abs"** - Returns the absolute value of a number.
* **max = "max"** - Returns the maximum value of a group of numbers.
* **round = "round"** - Rounds the given number.
* **avg = "avg"** - Returns the average of a group of numbers.
* **min = "min"** - Returns the minimum value of a group of numbers.
* **sum = "sum"** - Returns the sum of a group of numbers.
* **count = "count"** - Returns the number of records in a group.
* **random = "random"** - Returns a random number.
* **date = "date"** - Returns the date in this format: YYYY-MM-DD.
* **julianday = "julianday"** - Returns the current date in Julian notation.
* **strftime = "strftime"** - Formats the date as a string based on a set of formatting instructions.
* **datetime = "datetime"** - Returns the current date and time in the YYYY-MM-DD HH:MM:SS format.
* **now = "now"** - Returns the current date and time.
* **time = "time"** - Returns the time as HH:MM:SS
* **coalesce = "coalesce"** - Accepts two or more arguments and returns the first non-null argument.
* **lastInsertedRowID = "last_insert_rowid"** - Returns the ID of the last row inserted into any table.
* **ifNull = "ifnull"** - Accepts two or more arguments and returns the first non-null argument.
* **nullIf = "nullif"** - Returns `NULL` if any of the passed values are null.
* **check = "@check"** - Handles an internal check operation.
* **compare = "compare"** - Performs a comparison and returns one value if the comparison is `true` and another if it is `false`.

The `get` static method attempts to convert the given string value into a `ADSQLFunction` and ignores case. For example:

```swift
let key = ADSQLFunction.get("count")
```

<a name="ADSQLColumnType"></a>
## ADSQLColumnType

Defines the type of a column stored in a SQL data source:

* **nullType = "NULL"** - Database `NULL` is the same as a Swift `nil`.
* **integerType = "INTEGER"** - Holds any type of Swift integer data types (`Int`, `UInt`, `Int32`, etc.)
* **floatType = "FLOAT"** - Holds any Swift `Double` or `Float` value.
* **textType = "TEXT"** - Holds any Swift `String` value.
* **colorType = "COLOR"** - Holds a color definition as a text string in the form `#RRGGBBAA`.
* **blobType = "BLOB"** - Holds any Swift `Data` value. To store images, use the Action Utilities `toData()` method.
* **noneType = "NONE"** - The database has an undefined type and can hold any type of Swift data.
* **dateType = "DATE"** - Holds a Swift `Date` value.
* **boolType = "BOOLEAN"** - Holds a Swift `Bool` value.

The `get` static method attempts to convert the given string value into a `ADSQLColumnType` and ignores case. For example:

```swift
let key = ADSQLColumnType.get("integer")
```

The `set` method attempts to set the column type from a string value and ignores case. For example:

```swift
let type = ADSQLColumnType.noneType
type.set("text")
```

<a name="ADSQLParseError"></a>
## ADSQLParseError

Defines the type of errors that can arise when parsing a SQL command string. The `message` property contains the details of the given failure:

* **unknownKeyword(message: String)** - The parser encountered an unknown keyword in the SQL Command. `message` contains the details of the given failure.
* **unknownFunctionName(message: String)** - The parser encountered an unknown function name in the SQL Command. `message` contains the details of the given failure.
* **invalidKeyword(message: String)** - The parser encountered an invalid keyword in the SQL Command. `message` contains the details of the given failure.
* **mismatchedSingleQuotes(message: String)** - The parser encountered a value in single quotes that is not properly terminated. `message` contains the details of the given failure.
* **mismatchedDoubleQuotes(message: String)** - The parser encountered a value in double quotes that is not properly terminated. `message` contains the details of the given failure.
* **mismatchedParenthesis(message: String)** - The parser encountered a value in parenthesis that is not properly terminated. `message` contains the details of the given failure.
* **malformedSQLCommand(message: String)** - The parser encountered a value that it was not expecting. `message` contains the details of the given failure.
* **expectedIntValue(message: String)** - The parser expected an integer as the next value. `message` contains the details of the given failure.

<a name="ADSQLConflictHandling"></a>
## ADSQLConflictHandling

Defines the type of conflict handling that can be applied to a column or table constraint:

* **none** - No conflict handling.
* **rollback** - Rollback the changes.
* **abort** - Abort SQL statement execution.
* **fail** - Fail the execution.
* **ignore** - Ignore the issue.
* **replace** - Replace the value.