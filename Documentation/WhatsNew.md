# What's New

###Version 01.02###

The following features and bug fixes have been added to `Action Data` in version 01.02. This release includes the following features currently only available in iOS:

* **ADBoundViewController** - Provides a method to attach it to a data model (any Swift class or structure that conforms to the `Codable` protocol) and any control conforming to the `ADBindable` protocol on any **View** or **SubView** will automatically be populated with the values from the data model based on the `dataPath` property of the control.
* **ADBoundLabel** - Creates a label that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the label from or supply a formula in a SQL like syntax.
* **ADBoundTextField** - Creates a text field that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text field from or use a formula in a SQL like syntax.
* **ADBoundSlider** - Creates a slider that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the slider's value from or use a formula in a SQL like syntax.
* **ADBoundSwitch** - Creates a switch that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the switch from or a formula in a SQL like syntax.
* **ADBoundProgressView** - Creates a progress view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the progress from or a formula in a SQL like syntax.
* **ADBoundStepper** - Creates a stepper that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the stepper's value from or a formula in a SQL like syntax.
* **ADBoundImageView** - Creates an image view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the image view from or a formula in a SQL like syntax.
* **ADBoundTextView** - Creates a text view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text view from or a formula in a SQL like syntax.
* **ADBoundWebView** - Creates a web view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to use as the URL or the HTML data to display in the web view. Use the `containsHTML` property to decide if the `dataPath` contains a `URL` or `HTML` data.
* **ADBoundSegmentedControl** - Creates a segmented control that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to select the segment from or use a formula in a SQL like syntax. Use the `byTitle` property to decide if the segment is selected by title or integer position.
* **ADBoundTextPicker** - Creates a text field that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text field from or use a formula in a SQL like syntax. Includes a builtin picker control used to select the value from a list of available values.


###Version 01.01###

The following features and bug fixes have been added to `Action Data` in version 01.01. This release includes the following features:

* **Action SQL Parser** - Fixed issue with non-semicolon terminated SQL statements being reported as malformed.

###Version 01.00###

The following features and bug fixes have been added to `Action Data` in version 01.00. The initial release includes the following features:

* **Action Codable** - Uses Swift 4's new `Codable`, `Encodable` and `Decodable` protocols to move information between your data models and our portable `ADRecord` and `ADRecordSet` formats.
* **Action Data Providers** - Provides light weight, low-level access and high-level **Object Relationship Management** (ORM) support to several common databases and data formats such as SQLite and SPON.
* **Action SQL Parser** - Provides the ability to parse text containing one or more SQL commands into an **Action Data SQL Document Object Model** (DOM) and is used to provide SQL support for data sources that don't support SQL natively (such as CloudKit and JSON).
