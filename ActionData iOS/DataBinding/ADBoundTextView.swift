//
//  ADBoundTextView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a text view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text view from or a formula in a SQL like syntax.
 
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
 
 // Bind the text view to the description field
 myTextView.dataPath = "description"
 ```
 */
open class ADBoundTextView: UITextView, UITextViewDelegate, ADBindable, ADValidatable {
    
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
         var icon: Data = UIImage().toData()
     
         required init() {
     
         }
     }
     
     // Bind the text view to the description field
     myTextView.dataPath = "description"
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
     
     // Bind the text view to the enabled field
     myTextView.enabledPath = "enabled"
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
     myTextView.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /**
     The name of the field from the date model or formula (using SQL syntax) used to set the text color from.
     
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
     myTextView.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// If `true` this text view cause the parent `ADBoundViewController` to update the form when the value changes. Works with the `onEndEdit` property, if it's `true` the change will only be sent when the user finishes editing the field, else the change will be sent on individual character changes.
    @IBInspectable public var liveUpdate: Bool = false
    
    /// If `true`, the text view will be dimmed when it is not editable, else it will not be dimmed.
    @IBInspectable public var dimOnDisabled: Bool = true
    
    /// Works with the `liveUpdate` property, if it's `true` the change will only be sent when the user finishes editing the field, else the change will be sent on individual character changes.
    @IBInspectable public var onEndEdit: Bool = true
    
    /// If `true` a **Done** accessory button will be displayed along with the onscreen keyboard when this view is edited.
    @IBInspectable public var showDoneButton: Bool = true
    
    /// If `true` **Previous** and **Next** accessory buttons will be displayed along with the onscreen keyboard when this view is edited.
    @IBInspectable public var showPrevNextButtons: Bool = true
    
    /// Provides a link to the `ADBindingController` that the control is bound to.
    public var controller: ADBindingController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return isEditable}
    }
    
    /// If this bindable control is inside of a Sub View, this value is used to calculate the "physical" top of the control on the form. This value is used to determin if the control is being covered by the keyboard and if it should be moved. This value should never be set directly by the developer, it is automatically calculated by the `ADBindingController`.
    public var topOfFormOffset: Float = 0
    
    // MARK: - Validation Properties
    /// If `true` this control will be required to have a non-empty value (after trimming off any white space characters), else the field is not required to have a value.
    @IBInspectable public var validationRequired: Bool = false;
    
    /// Provides a formula in a SQL like syntax that is used to validate the value of the control (for example: `value IN('one','two','three')`). This formula should return a boolean result (`true` if passes validation, `false` elsewise), however, if the value is an `Int` or `Float` it will be converted to a `Bool` (1 = `true` and 0 = `false`. If the value is a `String` it will be converted to a `Bool` where the string values of "true", "yes" or "1" = `true` and the values of "false", "no" or "0" = `false`.
    @IBInspectable public var validationFormula: String = ""
    
    /// Provides the message that will be displayed when the value of this control fails validation (for example:`Please enter one, two or three for this field.`). If this message is not provided, a generic message will be presented.
    @IBInspectable public var validationMessage: String = ""
    
    /// If `true`, the value of this control will be validated before the control loses focus and resigns first responder.
    @IBInspectable public var instantValidation: Bool = false
    
    /// Returns `true` if the value in the control is valid, else returns `false` and displays a message about the field failing validation.
    public var isValid: Bool {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        var valid = true
        
        // Does the field require a value?
        if validationRequired {
            // Does the field contain a value?
            valid = (value != "")
        }
        
        // Has a validation formula been provided?
        if valid && validationFormula != "" {
            // Ask the controller to pull in the updated values
            controller!.updateRecord()
            
            // Attempt to execute the validation formula
            do {
                // Attempt to get value for path
                if let rawResult = try ADBoundPathProcessor.evaluate(path: validationFormula, against: controller!.record) {
                    // Did it pass the test?
                    valid = try ADUtilities.cast(rawResult, to: .boolType) as! Bool
                }
            } catch {
                // Output processing error
                print("Error evaluating validation formula path `\(validationFormula)`: \(error)")
                valid = false
            }
        }
        
        // Display failed validation message?
        if !valid {
            if validationMessage == "" {
                // Display a generic validation message
                controller!.displayValidationAlert(message: dataPath, isGeneric: true)
            } else {
                // Display the validation message
                controller!.displayValidationAlert(message: validationMessage, isGeneric: false)
            }
        }
        
        // Return results of test
        return valid
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Mark self as delegate
        self.delegate = self
    }
    
    // MARK: - Deinitialization
    deinit {
        // Release memory
        controller = nil
    }
    
    // MARK: - Functions
    
    /**
     Sets the value of the text view from the given value. If the value is an `Int` or `Float` it will be converted to a string. If the value is a `Bool` it will be converted to the string values of `true` or `false`.
     
     - Parameter value: The value to set the text view to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            let label = try ADUtilities.cast(value, to: .textType) as! String
            text = label
        } catch {
            print("BINDING ERROR: Unable to set text view value from data path `\(dataPath)`.")
        }
    }
    
    /**
     Sets the enabled state of the control from the given value. If the value is an `Int` or `Float`, `0` and `1` will be converted to `false` and `true`. If the value is a `String`, "yes", "on", "true", "1" will be converted to `true`, all other values will result in `false`.
     
     - Parameter value: The value to set the enabled state from.
     - Remark: For a text view, **enabled** is mapped to **editable**.
     */
    public func setEnabledState(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a boolean
            let state = try ADUtilities.cast(value, to: .boolType) as! Bool
            if dimOnDisabled {
                if state {
                    alpha = 1.0
                } else {
                    alpha = 0.7
                }
            }
            isEditable = state
        } catch {
            print("BINDING ERROR: Unable to set text view enabled state from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set text view hidden state from data path `\(dataPath)`.")
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
     Returns the value of the text view.
     
     - Returns: The value of the text view as a `String`.
     */
    public func getValue() -> Any {
        if let value = text  {
            return value
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
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // Requires accessories?
        if showPrevNextButtons || showDoneButton {
            // Build the required accessory view
            buildAccessoryView()
        } else {
            // Remove accessories
            self.inputAccessoryView = nil
        }
        
        // Allow editing
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        // Move field into view if needed
        if let bindEngine = controller {
            bindEngine.moveViewToExposeField(withFrame: frame, andOffset: topOfFormOffset)
        }
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        // Requires instant validation?
        if instantValidation {
            // Yes, only allow to end if value is valid
            return isValid
        } else {
            // No, allow editing to end
            return true
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // Live updating on value change?
        if liveUpdate && !onEndEdit {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
