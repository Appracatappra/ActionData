//
//  ADBoundProgressView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a progress view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the progress from.
 
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
     var percentage = 100
     var icon: Data = UIImage().toData()
 
     required init() {
 
     }
 }
 
 // Bind the progress to the percentage field
 myProgress.dataPath = "percentage"
 ```
 */
@IBDesignable open class ADBoundProgressView: UIProgressView, ADBindable {
    
    // MARK: - Private variables
    /// The minimum value for the progress.
    var minimum: Float = 0.0
    
    /// The maximum value for the progress.
    var maximum: Float = 1.0
    
    /**
     The name of the field from the date model used to populate the value from.
     
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
         var percentage = 100
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Bind the progress to the percentage field
     myProgress.dataPath = "percentage"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`.
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
     
     // Bind the progress view to the enabled field
     myProgressView.enabledPath = "enabled"
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
     myProgressView.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
    public weak var controller: ADBoundViewController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /**
     Sets the minimum value for the progress.
    */
    @IBInspectable public var minValue: Float{
        get {return minimum}
        set {
            if newValue > maximum {
                minimum = maximum
            } else {
                minimum = newValue
            }
        }
    }
    
    /**
     Sets the maximum value for the progress.
     */
    @IBInspectable public var maxValue: Float {
        get {return maximum}
        set {
            if newValue < minimum {
                maximum = minimum
            } else {
                maximum = newValue
            }
        }
    }
    
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
     Sets the value of the progress from the given value. If the value is a `String`, this function will attempt to convert it to a `Float`.
     
     - Parameter value: The value to set the progress to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a float and display it
            let amount = try ADUtilities.cast(value, to: .floatType) as! Float
            progress = amount / (maximum - minimum)
        } catch {
            print("BINDING ERROR: Unable to set progress view value from data path `\(dataPath)`.")
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
            // TODO: Handle isEnabled = state
        } catch {
            print("BINDING ERROR: Unable to set progress view enabled state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the hidden state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the enabled state from.
     */
    public func setHiddenState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            isHidden = state
        } catch {
            print("BINDING ERROR: Unable to set progress view hidden state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Returns the value of the progress.
     
     - Returns: The value of the progress view as a `Float`.
     */
    public func getValue() -> Any {
        return progress * (maximum - minimum)
    }
    
}
