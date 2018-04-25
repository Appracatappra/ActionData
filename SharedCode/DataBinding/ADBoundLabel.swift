//
//  ADBoundLabel.swift
//  ActionData
//
//  Created by Kevin Mullins on 4/12/18.
//

import Foundation

/**
 Creates a label that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the label from.
 
 ## Example:
 ```swift
 // Given the following class
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
 
 // Bind the label to the name field
 myLabel.dataPath = "name"
 ```
 */
@IBDesignable open class ADBoundLabel: UILabel, ADBindable {
    
    /**
     The name of the field from the date model or forumla (using SQL syntax) used to populate the value from.
     
     ## Example:
     ```swift
     // Given the following class
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
     
     // Bind the label to the name field
     myLabel.dataPath = "name"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
    */
    @IBInspectable public var dataPath: String = ""
    
    /**
     The name of the field from the date model or forumla (using SQL syntax) used to set the enabled state from.
     
     ## Example:
     ```swift
     // Given the following class
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
     
     // Bind the label to the enabled field
     myLabel.enabledPath = "enabled"
     ```
     
     - remark: The case and name of the field specified in the `enabledPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var enabledPath: String = ""
    
    /**
     The name of the field from the date model or forumla (using SQL syntax) used to set the hidden state from.
     
     ## Example:
     ```swift
     // Given the following class
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
         var quantity = 0
         var highlightColor = UIColor.white.toHex()
         var type: CategoryType = .local
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Set the hidden state based on a formula.
     myLabel.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /**
     The name of the field from the date model or forumla (using SQL syntax) used to set the text color from.
     
     ## Example:
     ```swift
     // Given the following class
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
         var quantity = 0
         var highlightColor = UIColor.white.toHex()
         var type: CategoryType = .local
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Set the text color based on a formula.
     myLabel.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// Defines the type of formatter that will be used to format the value of this text field before it is displayed to the user. The currently supported formats are "number", "masked" or "date".
    @IBInspectable public var formatType: String = ""
    
    /// Works with the `formatType` property to format the value that is displayed to the user based on the pattern given in this string. For example, "$###,###.00" for a number or "mm/dd/yyyy" for a date.
    @IBInspectable public var formatPattern: String = ""
    
    /// Built-in number formatter used with the `formatType` and `formatPattern` properties to automatically format numeric values.
    public var numberFormatter = NumberFormatter()
    
    /// Built-in date formatted used with the `formatType` and `formatPattern` properties to automatically format date/time values.
    public var dateFormatter = DateFormatter()
    
    /// Built-in masked string formatter used with the `formatType` and `formatPattern` properties to automatically format string values.
    public var maskedFormatter = ADMaskedStringFormatter()
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
    public weak var controller: ADBoundViewController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
    */
    public var formID: Int = -1
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return false}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Functions
    /**
     Sets the value of the label from the given value. If the value is an `Int` or `Float` it will be converted to a string. If the value is a `Bool` it will be converted to the string values of `true` or `false`.
     
     - Parameter value: The value to set the label to.
    */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            // Take action based on the type of format
            switch formatType.lowercased() {
            case "number":
                // Attempt to format as a number
                numberFormatter.negativeFormat = formatPattern
                numberFormatter.positiveFormat = formatPattern
                
                let val = try ADUtilities.cast(value, to: .floatType) as! Float
                text = numberFormatter.string(from: NSNumber(value: val))
            case "masked":
                // Set format
                maskedFormatter.formatString = formatPattern
                
                // Apply format
                let val = try ADUtilities.cast(value, to: .textType) as! String
                text = maskedFormatter.applyFormat(to: val)
            case "date":
                // Attempt to format as a date
                dateFormatter.dateFormat = formatPattern
                
                let dt = try ADUtilities.cast(value, to: .dateType) as! Date
                text = dateFormatter.string(from: dt)
            default:
                // Use raw value
                let label = try ADUtilities.cast(value, to: .textType) as! String
                text = label
            }
        } catch {
            print("BINDING ERROR: Unable to set label value from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the enabled state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the enabled state from.
    */
    public func setEnabledState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            isEnabled = state
        } catch {
            print("BINDING ERROR: Unable to set label enabled state from data path `\(enabledPath)`.")
        }
    }
    
    /**
     Sets the hidden state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the hidden state from.
     */
    public func setHiddenState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            isHidden = state
        } catch {
            print("BINDING ERROR: Unable to set label hidden state from data path `\(hiddenPath)`.")
        }
    }
    
    /**
     Sets the text color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the text color from.
    */
    public func setTextColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            textColor = color
        } catch {
            print("BINDING ERROR: Unable to set text color from data path `\(colorPath)`.")
        }
    }
    
    /**
     Sets any control specific bound states (such as colors) with the values from the given `ADRecord`.
     
     - Parameter data: The raw data to bind the additional states to.
    */
    public func setControlSpecificStates(against data: ADRecord) {
        // Set text color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: colorPath, against: data) {
                setTextColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating text color path `\(colorPath)`: \(error)")
        }
    }
    
    /**
     Returns the value of the label.
     
     - Returns: The value of the label as a `String`.
    */
    public func getValue() -> Any {
        if let value = text  {
            return value
        } else {
            return ""
        }
    }
    
}
