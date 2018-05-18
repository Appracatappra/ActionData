//
//  ADBoundTextPicker.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/20/18.
//

import Foundation

/**
 Creates a text field that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the text field from or use a formula in a SQL like syntax. Includes a builtin picker control used to select the value from a list of available values.
 
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
open class ADBoundTextPicker: UITextField, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ADBindable {
    
    
    
    // MARK: - Private Variables
    /// Holds the backing data for the string of available options that can be set in Interface Builder.
    private var availableOptions = "One,Two,Three"
    
    /// Holds the built in data picker that will be used to select a new value from.
    private var valuePicker: UIPickerView?
    
    /// Holds the currently selected value.
    private var selectedValue: String?
    
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
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var dataPath: String = ""
    
    /// Sets the title that is displayed over the picker view.
    @IBInspectable public var title: String = ""
    
    /// Defines a comma separated list of options that will be displayed in the attached picker controller for the user to select from. Updating this property will automatically update the `optionList` property.
    @IBInspectable public var optionValues: String {
        get { return availableOptions}
        set {
            // Save value
            availableOptions = newValue
            
            // Update the tied list of options
            optionList = availableOptions.components(separatedBy: ",")
        }
    }
    
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
     
     // Bind the text field to the enabled field
     myTextField.enabledPath = "enabled"
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
     myTextField.hiddenPath = "quantity > 0"
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
     myTextPicker.colorPath = "highlightColor"
     ```
     
     - remark: The case and name of the field specified in the `colorPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a formula using a subset of the SQL syntax.
     */
    @IBInspectable public var colorPath: String = ""
    
    /// If `true` this text view cause the parent `ADBoundViewController` to update the form when the value changes. 
    @IBInspectable public var liveUpdate: Bool = false
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
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
    
    /// Gets or sets the list of options that will be displayed in the picker view when the users edits the field.
    public var optionList: [String] = ["One", "Two", "Three"]
    
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
     Sets the value of the text field from the given value. If the value is an `Int` or `Float` it will be converted to a string. If the value is a `Bool` it will be converted to the string values of `true` or `false`.
     
     - Parameter value: The value to set the text field to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            let label = try ADUtilities.cast(value, to: .textType) as! String
            text = label
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
            return value
        } else {
            return ""
        }
    }
    
    /**
     Creates the picker and toolbar that will be attached to the field when the user selects to edit it.
     */
    private func buildAccessoryView() {
        // Create the required picker view
        valuePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
        valuePicker!.delegate = self
        valuePicker!.dataSource = self
        valuePicker!.backgroundColor = UIColor.white
        
        // Attach to textview
        inputView = valuePicker
        
        // Create new toolbar
        let toolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = []
        
        // Add done button
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelButtonAction))
        toolbar.items?.append(cancel)
        
        // Add space
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items?.append(flexSpace)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        label.text = title
        label.font = UIFont(name: "System", size: CGFloat(8))
        label.textAlignment = .center
        let lableItem = UIBarButtonItem(customView: label)
        toolbar.items?.append(lableItem)
        
        toolbar.items?.append(flexSpace)
        
        // Add done button
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        toolbar.items?.append(done)
        
        // Configure button
        if let bindEngine = controller {
            done.title = bindEngine.doneButtonText
            done.image = bindEngine.doneButtonImage
            
            cancel.title = bindEngine.cancelButtonText
            cancel.image = bindEngine.cancelButtonImage
        }
        
        // Attach toolbar to self
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    /**
     Closes the picker when the use taps the **Cancel** button on the toolbar attached to the picker.
     */
    @objc private func cancelButtonAction() {
        // Reset the selected value
        selectedValue = text
        
        // Close the picker
        self.resignFirstResponder()
    }
    
    /**
     Closes the picker and sets the new value when the use taps the **Done** button on the toolbar attached to the picker.
     */
    @objc private func doneButtonAction()
    {
        // Set the value to the new value selected
        text = selectedValue
        
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
        
        // Close the picker
        self.resignFirstResponder()
    }
    
    // MARK: - Text View Delegate Functions
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Build and attache the input picker
        buildAccessoryView()
        
        // Save the current value
        selectedValue = text
        
        // Allow edit to take place.
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        // Move field into view if needed
        if let bindEngine = controller {
            bindEngine.moveViewToExposeField(withFrame: frame, andOffset: topOfFormOffset)
        }
        
        // Auto pick the currently selected item
        if let currentValue = text {
            var n = 0
            for option in optionList {
                if currentValue == option {
                    valuePicker?.selectRow(n, inComponent: 0, animated: false)
                    break
                }
                n += 1
            }
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Always allow change
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: - Picker Data Source Delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionList.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // Return the requested option
        return optionList[row]
    }
    
    // MARK: - Picker View Delegate
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Save selected value
        selectedValue = optionList[row]
    }
}
