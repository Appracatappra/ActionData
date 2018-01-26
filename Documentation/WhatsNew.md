# What's New

###Version 01.00###

The following features and bug fixes have been added to `Action Data` in version 01.00. The initial release includes the following features:

* **Action Codable** - Uses Swift 4's new `Codable`, `Encodable` and `Decodable` protocols to move information between your data models and our portable `ADRecord` and `ADRecordSet` formats.
* **Action Data Providers** - Provides light weight, low-level access and high-level **Object Relationship Management** (ORM) support to several common databases and data formats such as SQLite and SPON.
* **Action SQL Parser** - Provides the ability to parse text containing one or more SQL commands into an **Action Data SQL Document Object Model** (DOM) and is used to provide SQL support for data sources that don't support SQL natively (such as CloudKit and JSON).
