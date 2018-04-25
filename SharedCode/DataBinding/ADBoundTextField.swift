//
//  ADBoundTextField.swift
//  ActionData
//
//  Created by Kevin Mullins on 4/12/18.
//

import Foundation

/**
 Creates a text field that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text field from.
 
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
 myTextField.dataPath = "name"
 ```
 */
open class ADBoundTextField: UITextField, UITextFieldDelegate, ADBindable {
    
    // MARK: - Computed Properties
    
    /**
     The name of the field from the date model or formula (in the SQL syntax) used to populate the value from.
     
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
     myTextField.dataPath = "name"
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
     
     // Bind the text field to the enabled field
     myTextField.enabledPath = "enabled"
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
     myTextField.hiddenPath = "quantity > 0"
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
     myTextField.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// If `true` this text view cause the parent `ADBoundViewController` to update the form when the value changes. Works with the `onEndEdit` property, if it's `true` the change will only be sent when the user finishes editing the field, else the change will be sent on individual character changes.
    @IBInspectable public var liveUpdate: Bool = false
    
    /// Works with the `liveUpdate` property, if it's `true` the change will only be sent when the user finishes editing the field, else the change will be sent on individual character changes.
    @IBInspectable public var onEndEdit: Bool = true
    
    /// If `true` a **Done** accessory button will be displayed along with the onscreen keyboard when this field is edited.
    @IBInspectable public var showDoneButton: Bool = true
    
    /// If `true` **Previous** and **Next** accessory buttons will be displayed along with the onscreen keyboard when this field is edited.
    @IBInspectable public var showPrevNextButtons: Bool = true
    
    /// If `true` this `ADBoundTextField` will resign first responder and close the onscreen keyboard when the **Return** key is tapped.
    @IBInspectable public var closeOnReturn: Bool = false
    
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
        get {return true}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Mark self as delegate
        self.delegate = self
        
        // Configure formatters
        numberFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
    }
    
    // MARK: - Functions
    /**
     Sets the value of the text field from the given value. If the value is an `Int` or `Float` it will be converted to a string. If the value is a `Bool` it will be converted to the string values of `true` or `false`.
     
     - Parameter value: The value to set the text field to.
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
            print("BINDING ERROR: Unable to set text field value from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set text field enabled state from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set text field hidden state from data path `\(dataPath)`.")
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
     Returns the value of the text field.
     
     - Returns: The value of the text Field as a `String`.
     */
    public func getValue() -> Any {
        if let value = text  {
            switch formatType.lowercased() {
            case "number":
                if let num = numberFormatter.number(from: value) {
                    return num
                } else {
                    return 0
                }
            case "masked":
                return maskedFormatter.removeFormat(from: value)
            default:
                // Non-formatted, return as-is
                return value
            }
            
        } else {
            return ""
        }
    }
    
    /**
     Create an accessory toolbar with the required previous, next and/or done buttons and attaches it to this field. This toolbar will be displayed along with the onscreen toolbar.
    */
    private func buildAccessoryView() {
        // Create new toolbar
        let toolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = []
        
        // Has previous and next buttons?
        if showPrevNextButtons {
            // Add previous button
            let prev: UIBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(self.previousButtonAction))
            toolbar.items?.append(prev)
            
            // Add next button
            let next: UIBarButtonItem = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(self.nextButtonAction))
            toolbar.items?.append(next)
            
            // Configure buttons
            if let bindEngine = controller {
                // Setup Prev button.
                prev.title = bindEngine.prevButtonText
                prev.image = bindEngine.prevButtonImage
                
                // Setup the Next button
                next.title = bindEngine.nextButtonText
                next.image = bindEngine.nextButtonImage
                
                // Enabled?
                prev.isEnabled = bindEngine.hasPrevTextFieldOrView(beforeField: formID)
                next.isEnabled = bindEngine.hasNextTextFieldOrView(afterField: formID)
            }
        }
        
        // Has done button?
        if showDoneButton {
            // Add space
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.items?.append(flexSpace)
            
            // Add done button
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
            toolbar.items?.append(done)
            
            // Configure button
            if let bindEngine = controller {
                done.title = bindEngine.doneButtonText
                done.image = bindEngine.doneButtonImage
            }
        }
        
        // Attach toolbar to self
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    /**
     Moves to the previous text field or view when the use taps the **Previous** button on the toolbar attached to the keyboard.
    */
    @objc private func previousButtonAction() {
        // Take action
        if let bindEngine = controller {
            bindEngine.moveToPrevTextFieldOrView(beforeField: formID)
        }
    }
    
    /**
     Moves to the next text field or view when the use taps the **Previous** button on the toolbar attached to the keyboard.
     */
    @objc private func nextButtonAction() {
        // Take action
        if let bindEngine = controller {
            bindEngine.moveToNextTextFieldOrView(afterField: formID)
        }
    }
    
    /**
     Closes the keyboard when the use taps the **Done** button on the toolbar attached to the keyboard.
    */
    @objc private func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    // MARK: - Delegate Functions
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Requires accessories?
        if showPrevNextButtons || showDoneButton {
            // Build the required accessory view
            buildAccessoryView()
        } else {
            // Remove accessories
            self.inputAccessoryView = nil
        }
        
        // Allow edit to take place.
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // Move field into view if needed
        if let bindEngine = controller {
            bindEngine.moveViewToExposeField(withFrame: frame)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Live updating on value change?
        if liveUpdate && !onEndEdit {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
        
        // Always allow change
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Should we resign first responder?
        if closeOnReturn {
            // Yes, stop editing and close the onscreen keyboard
            resignFirstResponder()
        }
        
        // Allow return
        return true
    }
}
