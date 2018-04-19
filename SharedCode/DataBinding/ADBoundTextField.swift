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
     
     // Bind the label to the name field
     myTextField.dataPath = "name"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`.
     */
    @IBInspectable public var dataPath: String = ""
    
    /// If `true` a **Done** accessory button will be displayed along with the onscreen keyboard when this field is edited.
    @IBInspectable public var showDoneButton: Bool = true
    
    /// If `true` **Previous** and **Next** accessory buttons will be displayed along with the onscreen keyboard when this field is edited.
    @IBInspectable public var showPrevNextButtons: Bool = true
    
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
            print("BINDING ERROR: Unable to set value from data path `\(dataPath)`.")
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
        
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
