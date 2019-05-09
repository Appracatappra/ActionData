//
//  ADBoundStepper.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a stepper that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the stepper's value from or a formula in a SQL like syntax.
 
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
 
 // Bind the stepper to the percentage field
 myStepper.dataPath = "percentage"
 ```
 */
open class ADBoundStepper: UIStepper, ADBindable {
    
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
     
     // Bind the stepper to the percentage field
     myStepper.dataPath = "percentage"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`.
     */
    @IBInspectable public var dataPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the enabled state from.
     
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
     
     // Bind the stepper to the enabled field
     myStepper.enabledPath = "enabled"
     ```
     
     - remark: The case and name of the field specified in the `enabledPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var enabledPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the hidden state from.
     
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
     myStepper.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the tint color from.
     
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
     myStepper.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// If `true` this stepper cause the parent `ADBoundViewController` to update the form as the value changes.
    @IBInspectable public var liveUpdate: Bool = false
    
    /// Provides a link to the `ADBindingController` that the control is bound to.
    public var controller: ADBindingController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return true}
    }
    
    /// If this bindable control is inside of a Sub View, this value is used to calculate the "physical" top of the control on the form. This value is used to determin if the control is being covered by the keyboard and if it should be moved. This value should never be set directly by the developer, it is automatically calculated by the `ADBindingController`.
    public var topOfFormOffset: Float = 0
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Watch value change
        addTarget(self, action: #selector(controlValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    
    // MARK: - Deinitialization
    deinit {
        // Release memory
        controller = nil
    }
    
    // MARK: - Functions
    /**
     Handles the value of the control being changed.
     
     - Parameter sender: The control that was changed.
     */
    @objc internal func controlValueChanged(sender : UIStepper) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    /**
     Sets the value of the stepper from the given value. If the value is a `String`, it will attempted to be converted to a `Float`.
     
     - Parameter value: The value to set the stepper to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a float and display it
            let amount = try ADUtilities.cast(value, to: .floatType) as! Float
            self.value = Double(amount)
        } catch {
            print("BINDING ERROR: Unable to set stepper value from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set stepper enabled state from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set stepper hidden state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the tint color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the text color from.
     */
    public func setTintColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            tintColor = color
        } catch {
            print("BINDING ERROR: Unable to set tint color from data path `\(colorPath)`.")
        }
    }
    
    /**
     Sets any control specific bound states (such as colors) with the values from the given `ADRecord`.
     
     - Parameter data: The raw data to bind the additional states to.
     */
    public func setControlSpecificStates(against data: ADRecord) {
        // Set tint color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: colorPath, against: data) {
                setTintColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating tint color path `\(colorPath)`: \(error)")
        }
    }
    
    /**
     Returns the value of the stepper.
     
     - Returns: The value of the slider as a `Float`.
     */
    public func getValue() -> Any {
        return Float(value)
    }
    
}
