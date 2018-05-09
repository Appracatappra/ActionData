//
//  ADBoundSlider.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a slider that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the slider's value from or use a formula in a SQL like syntax.
 
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
 
 // Bind the slider to the percentage field
 mySlider.dataPath = "percentage"
 ```
 */
@IBDesignable open class ADBoundSlider: UISlider, ADBindable {
    
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
     
     // Bind the slide to the percentage field
     mySlider.dataPath = "percentage"
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
     
     // Bind the slider to the enabled field
     mySlider.enabledPath = "enabled"
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
     mySlider.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the minimum track tint color from.
     
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
     mySlider.minColorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `minColorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var minColorPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the maximum track tint color from.
     
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
     mySlider.maxColorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `maxColorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var maxColorPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the thumb tint color from.
     
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
     mySlider.thumbColorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `thumbColorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var thumbColorPath: String = ""
    
    /// If `true` this slider cause the parent `ADBoundViewController` to update the form as the value of the slider changes.
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
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Watch value chage
        addTarget(self, action: #selector(sliderValueChanged(sender:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK: - Deinitialization
    deinit {
        // Release memory
        controller = nil
    }
    
    // MARK: - Functions
    /**
     Handles the value of the slider being changed.
     
     - Parameter sender: The slider that was changed.
    */
    @objc internal func sliderValueChanged(sender : UISlider) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    /**
     Sets the value of the slider from the given value. If the value is a `String`, it will attempted to be converted to a `Float`.
     
     - Parameter value: The value to set the slider to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a string and display it
            let amount = try ADUtilities.cast(value, to: .floatType) as! Float
            self.value = amount
        } catch {
            print("BINDING ERROR: Unable to set slider value from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set slider enabled state from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set slider hidden state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the minimum track color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the minimum track color from.
     */
    public func setMinColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            minimumTrackTintColor = color
        } catch {
            print("BINDING ERROR: Unable to set minimum track color from data path `\(minColorPath)`.")
        }
    }
    
    /**
     Sets the maximum track color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the text color from.
     */
    public func setMaxColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            maximumTrackTintColor = color
        } catch {
            print("BINDING ERROR: Unable to set maximum track color from data path `\(maxColorPath)`.")
        }
    }
    
    /**
     Sets the thumb color from the given value. If the value is a string, this routine will assume it holds a hex color specification in the form `#RRGGBBAA`.
     
     - Parameter value: The value to set the text color from.
     */
    public func setThumbColor(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let color = try ADUtilities.cast(value, to: .colorType) as! UIColor
            thumbTintColor = color
        } catch {
            print("BINDING ERROR: Unable to set text color from data path `\(thumbColorPath)`.")
        }
    }
    
    /**
     Sets any control specific bound states (such as colors) with the values from the given `ADRecord`.
     
     - Parameter data: The raw data to bind the additional states to.
     */
    public func setControlSpecificStates(against data: ADRecord) {
        // Set min color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: minColorPath, against: data) {
                setMinColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating minimum color path `\(minColorPath)`: \(error)")
        }
        
        // Set maximum color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: maxColorPath, against: data) {
                setMaxColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating maximum color path `\(maxColorPath)`: \(error)")
        }
        
        // Set thumb color
        do {
            // Attempt to get value for path
            if let value = try ADBoundPathProcessor.evaluate(path: thumbColorPath, against: data) {
                setThumbColor(value)
            }
        } catch {
            // Output processing error
            print("Error evaluating thumb color path `\(thumbColorPath)`: \(error)")
        }
    }
    
    /**
     Returns the value of the slider.
     
     - Returns: The value of the slider as a `Float`.
     */
    public func getValue() -> Any {
        return value
    }
    
}
