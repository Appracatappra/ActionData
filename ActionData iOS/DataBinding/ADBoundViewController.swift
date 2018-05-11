//
//  ADBoundViewController.swift
//  ActionData
//
//  Created by Kevin Mullins on 4/12/18.
//

import Foundation

/**
 A `ADBoundViewController` provides a method to attach it to a data model (any Swift class or structure that conforms to the `Codable` protocol) and any control conforming to the `ADBindable` protocol on any **View** or **SubView** will automatically be populated with the values from the data model based on the `dataPath` property of the control. The `dataPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
 
 By using the `setDataModel` function to set the model and automatically populate the fields, you to not need to create **Actions** or **Outlets** for the individual controls. The `ADBoundViewController` will automatically handle the reading and writing of properties for you.
 
 For any `ADBindable` control that is editable, calling the `getDataModel` function will return the values from the controls on the **View** and **SubViews**. These will be written to the field of the data model as specified by the `dataPath` property of the control, as a result, a formula should not be used for the `dataPath` of any field that is readable.
 
 For any field that requires onscreen keyboard support, the `ADBoundViewController` will automatically handle keyboard events such as moving fields hidden by the keyboard so they are visible and moving them back after they lose focus. Accessory tools can be automatically added to the keyboard to move between the text entry fields and to close the keyboard based on options for each control. These buttons can be customized using the `prevButtonText`, `prevButtonImage`, `nextButtonText`, `nextButtonImage`, `doneButtonText` and `doneButtonImage` properties of the `ADBoundViewController`.
 
 The `ADBoundTextPicker` control has an embedded picker view that will be handled automatically by the `ADBoundViewController` in a similar fashion as the onscreen keyboard. If the field is covered by the picker, it will be moved automatically to be shown and moved back when the picker is closed. An accessory toolbar will be added to the picker that can be customized with the `cancelButtonText`, `cancelButtonImage`, `doneButtonText` and `doneButtonImage` properties of the `ADBoundViewController`.
 
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
 
 // Populate any control on the View with values from the data model
 let category = Category(name: "Swift File", description: "A file containing swift source code.")
 do {
    try setDataModel(category)
 } catch {
    print("Failed to set data model")
 }
 
 // Read the vaules back from the controls
 do {
     let category = try getDataModel(Category.self)
     print("Category Description: \(category.description)")
 } catch {
    print("Unable to read data model")
 }
 ```
 */
open class ADBoundViewController: UIViewController, ADBindingController {
    
    // MARK: - Private Variables
    /// The internal encoder used to convert the data model into a `ADRecord` for working with the bounds controls.
    private let encoder = ADSQLEncoder()
    
    /// The internal decoder used to convert the `ADRecord` back into a data model with the values from the bound controls.
    private let decoder = ADSQLDecoder()
    
    /// An array of all bound controls discovered in the View and Subview controlled by this `ADBoundViewController`.
    private var controls: [ADBindable] = []
    
    /// Create an array of keyboard notification events.
    private let keyboardNotifications: [Notification.Name] = [
        .UIKeyboardWillShow,
        .UIKeyboardWillHide,
        .UIKeyboardWillChangeFrame
        ]
    
    /// Holds the frame for the onscreen keyboard.
    private var keyboardFrame: CGRect?
    
    /// Holds the size of the keyboard when it is displayed.
    private var keyboardOffset: CGFloat = 0.0
    
    /// Holds the position of the next text field or view that is coming into focus.
    private var fieldPosition: CGFloat = 0.0
    
    /// `true` if the attached view has been moved up to expose a field that would typically be under the onscreen keyboard, `false` if not.
    private var viewMovedToExposeField: Bool = false
    
    // MARK: - Computed Properties
    /**
     A `ADRecord` representing the attached data model as a set of key/value pairs where the key is the name of the field that the value was read from or is writtne to. In between `setDataModel` and `getDataModel` function calls, use this property to interact with the values from the data model.
    */
    public var record: ADRecord = [:]
    
    /**
     Sets the text of the **Previous** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
    */
    @IBInspectable public var prevButtonText: String = "<"
    
    /**
     Sets the image of the **Previous** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    @IBInspectable public var prevButtonImage: UIImage?
    
    /**
     Sets the text of the **Next** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    @IBInspectable public var nextButtonText: String = ">"
    
    /**
     Sets the image of the **Next** button for `ADBoundTextField` and `ADBoundTextView` controls that show the previous and next accessory buttons.
     */
    @IBInspectable public var nextButtonImage: UIImage?
    
    /**
     Sets the text of the **Done** button for `ADBoundTextField`, `ADBoundTextPicker` and `ADBoundTextView` controls that show the done accessory button.
     */
    @IBInspectable public var doneButtonText: String = "Done"
    
    /**
     Sets the image of the **Done** button for `ADBoundTextField`, `ADBoundTextPicker` and `ADBoundTextView` controls that show the done accessory button.
     */
    @IBInspectable public var doneButtonImage: UIImage?
    
    /**
     Sets the text of the **Cancel** button for `ADBoundTextPicker` control that show the cancel accessory button.
     */
    @IBInspectable public var cancelButtonText: String = "Cancel"
    
    /**
     Sets the image of the **Cancel** button for `ADBoundTextPicker` control that show the cancel accessory button.
     */
    @IBInspectable public var cancelButtonImage: UIImage?
    
    /// The title of the alert that is displayed when a field fails automatic validation.
    @IBInspectable public var validationTitle: String = "Invalid Input"
    
    /// The generic message that is displayed in the alert when a field fails automatic validation. Use `$0` in the message anywhere you want the value of the `dataPath` presenting the message to be inserted.
    @IBInspectable public var validationMessage: String = "Please enter a valid value for $0."
    
    /// The text for the dismiss button that is displayed on the alert when a field fails automatic validation.
    @IBInspectable public var validationButtonText: String = "Ok"
    
    // MARK: - Initializers
    /// Initializes a new instance of the `ADBoundViewController`.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Functions
    /**
     Works with automatic validation to display a message when a field fails validation.
     
     - Parameter message: The message to display when a field fails validation.
     - Parameter isGeneric: If `true` the generic message will be combined with the passed value to present the message on the alert, else the message will be displayed as-is.
     
     - Remark: Any occurrances of `$0` in the `validationMessage` string will be replaced with the passed in message when the `isGeneric` parameter is `true`
    */
    public func displayValidationAlert(message: String, isGeneric: Bool = false) {
        
        // Create alert
        let alert = UIAlertController(title: validationTitle, message: isGeneric ? validationMessage.replacingOccurrences(of: "$0", with: message) : message, preferredStyle: .alert)
        
        // Add an action button
        alert.addAction(UIAlertAction(title: validationButtonText, style: .default, handler: nil))
        
        // Display alert
        self.present(alert, animated: true)
    }
    
    /**
     Attaches the given data model (any Swift class or structure conforming to the `Codable` protocol) to the `ADBoundViewController` populating the `record` property and any control conforming to the `ADBindable` protocol on any View or SubView.
     
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
     
     // Populate any control on the View with values from the data model
     let category = Category(name: "Swift File", description: "A file containing swift source code.")
     do {
        try setDataModel(category)
     } catch {
        print("Failed to set data model")
     }
     ```
     
     - Parameter value: A Swift class or structure conforming to the `Codeable` protocol.
    */
    public func setDataModel<T:Encodable>(_ value: T) throws {
        let model = try encoder.encode(value)
        if let data = model as? ADRecord {
            // Save model data
            record = data
            
            // Update bindings with new data
            setBoundValues()
        }
    }
    
    /**
     Reads the values from any editable control conforming to the `ADBindable` protocol into the given data model (any Swift class or structure conforming to the `Codable` protocol).
     
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
     
     // Read the vaules back from the controls
     do {
        let category = try getDataModel(Category.self)
        print("Category Description: \(category.description)")
     } catch {
        print("Unable to read data model")
     }
     ```
     
     - Parameter type: The type of a Swift class or structure conforming to the `Codeable` protocol to read the values into and return.
     
     - Returns: A class of the given type populated with any values read from the control conforming to the `ADBindable` protocol on any View or SubView controlled by this `ADBoundViewController`.
    */
    public func getDataModel<T:Decodable>(_ type: T.Type) throws -> T {
        // Read values from bound controls
        getBoundValues()
        
        // Attempt to convert back to data model
        return try decoder.decode(T.self, from: record)
    }
    
    /**
     Forces the `ADBoundViewController` to update the values of any control conforming to the `ADBindable` protocol on any **View** or **SubView** controlled by this `ADBoundViewController` with the values from the `record` property.
    */
    public func updateBindings() {
        setBoundValues()
    }
    
    /**
     Forces the `ADBoundViewController` to update the `record` property with the values from any editable control conforming to the `ADBindable` protocol on any View or SubView controlled by this `ADBoundViewController`.
    */
    public func updateRecord() {
        getBoundValues()
    }
    
    /**
      Forces the `ADBoundViewController` to read the values from any bound control in the `controls` array into the `record` property and write the values back to the bound controls to refresh the view.
    */
    public func refreshDisplay() {
        // Get new values
        getBoundValues()
        
        // Update the controls with the new values
        setBoundValues()
    }
    
    /**
     Scans the **View** and **SubViews** controlled by this `ADBoundViewController` for any control conforming to the `ADBindable` protocol and collects them in the `controls` array.
     
     - Parameter parentView: The View to scan for controls.
    */
    private func scanView(_ parentView: UIView) {
        // Scan all subviews
        for view in parentView.subviews {
            if var boundControl = view as? ADBindable {
                // Attach control to this controller
                boundControl.controller = self
                
                // Assign a form ID to the control
                boundControl.formID = controls.count
                
                // Add the control to the collection of known controls
                controls.append(boundControl)
            }
            
            // Check for any sub controls
            scanView(view)
        }
    }
    
    /**
     Takes the values from the `record` property and writes them to any control in the `controls` array where the `dataPath` matches the name of a key from the `record` dictionary.
    */
    internal func setBoundValues() {
        // Process all controls
        for control in controls {
            // Set value
            do {
                // Attempt to get value for path
                if let value = try ADBoundPathProcessor.evaluate(path: control.dataPath, against: record) {
                    control.setValue(value)
                }
            } catch {
                // Output processing error
                print("Error evaluating value path `\(control.dataPath)`: \(error)")
            }
            
            // Set enabled state
            do {
                // Attempt to get value for path
                if let value = try ADBoundPathProcessor.evaluate(path: control.enabledPath, against: record) {
                    control.setEnabledState(value)
                }
            } catch {
                // Output processing error
                print("Error evaluating enabled state path `\(control.dataPath)`: \(error)")
            }
            
            // Set hidden state
            do {
                // Attempt to get value for path
                if let value = try ADBoundPathProcessor.evaluate(path: control.hiddenPath, against: record) {
                    control.setHiddenState(value)
                }
            } catch {
                // Output processing error
                print("Error evaluating hidden state path `\(control.dataPath)`: \(error)")
            }
            
            // Set any states specific to the give control
            control.setControlSpecificStates(against: record)
        }
    }
    
    /**
     Reads the value of any editable control in the `controls` array into the `record` property where the `dataPath` matches a key in the `record` dictionary.
    */
    internal func getBoundValues() {
        // Process all controls
        for control in controls {
            // Can the controls value be edited?
            if control.isMutable {
                // Does the dictionary contain the key?
                if let data = record[control.dataPath] {
                    // Get value from control
                    let value = control.getValue()
                    
                    // Attempt to save back to model
                    do {
                        if data is Float {
                            // Cast returned value to float
                            record[control.dataPath] = try ADUtilities.cast(value, to: .floatType)
                        } else if data is Int {
                            // Cast returned value to integer
                            record[control.dataPath] = try ADUtilities.cast(value, to: .integerType)
                        } else if data is Bool {
                            // Cast returned value to boolean
                            record[control.dataPath] = try ADUtilities.cast(value, to: .boolType)
                        } else if data is String {
                            // Cast returned value to string
                            record[control.dataPath] = try ADUtilities.cast(value, to: .textType)
                        } else {
                            print("BINDING ERROR: Data type not supported for data path `\(control.dataPath)`.")
                        }
                    } catch {
                        // Data conversion failed
                        print("BINDING ERROR: Unable to convert value for data path `\(control.dataPath)`.")
                    }
                }
            }
        }
    }
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` when it becomes first responder to see if the field is under the onscreen keyboard. If the field is under the keyboard, the field will be moved to expose the keyboard. If the view has already been moved and the field is not under the keyboard, the view will be moved back to its original position.
     
     - Parameter fieldFrame: The `GCRect` of the text field or view that has just gained focus.
    */
    public func moveViewToExposeField(withFrame fieldFrame: CGRect) {
        
        // Calculate the position of the field
        fieldPosition = fieldFrame.minY + fieldFrame.height
        
        // Move the view to avoid the keyboard if required.
        moveViewIfNeeded(animated: true)
    }
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to see if another `ADBoundTextField` or `ADBoundTextView` is in a higher location on the form.
     
     - Parameter id: The form ID of the control performing the check.
     - Returns: `true` if there is a previous text field or view, else returns `false`.
    */
    public func hasPrevTextFieldOrView(beforeField id: Int) -> Bool {
        var n = id - 1
        
        // Scan from requested location
        while n > 0 {
            // Get the requested field
            let field = controls[n]
            
            // Found?
            if field is ADBoundTextField || field is ADBoundTextView {
                // Yes
                return true
            }
            
            // Decrement
            n -= 1
        }
        
        // Not found
        return false
    }
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to see if another `ADBoundTextField` or `ADBoundTextView` is in a lower location on the form.
     
     - Parameter id: The form ID of the control performing the check.
     - Returns: `true` if there is a next text field or view, else returns `false`.
    */
    public func hasNextTextFieldOrView(afterField id: Int) -> Bool {
        
        // Scan from requested location
        for n in (id + 1)..<controls.count {
            // Get the requested field
            let field = controls[n]
            
            // Found?
            if field is ADBoundTextField || field is ADBoundTextView {
                // Yes
                return true
            }
        }
        
        // Not found
        return false
    }
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to move to a previous text field or view.
     
     - Parameter id: The form ID of the control performing the move.
    */
    public func moveToPrevTextFieldOrView(beforeField id: Int) {
        var n = id - 1
        
        // Scan from requested location
        while n > 0 {
            // Get the requested field
            let control = controls[n]
            
            // Found?
            if let field = control as? ADBoundTextField {
                // Move focus here
                field.becomeFirstResponder()
            } else if let view = control as? ADBoundTextView {
                // Move focus here
                view.becomeFirstResponder()
            }
            
            // Decrement
            n -= 1
        }
        
    }
    
    /**
     Called by a `ADBoundTextField` or `ADBoundTextView` to move to a next text field or view.
     
     - Parameter id: The form ID of the control performing the move.
     */
    public func moveToNextTextFieldOrView(afterField id: Int) {
        
        // Scan from requested location
        for n in (id + 1)..<controls.count {
            // Get the requested field
            let control = controls[n]
            
            // Found?
            if let field = control as? ADBoundTextField {
                // Move focus here
                field.becomeFirstResponder()
            } else if let view = control as? ADBoundTextView {
                // Move focus here
                view.becomeFirstResponder()
            }
        }
    }
    
    /**
     Moves the underlying `view` attached to this `ADBoundViewController` if the currently selected field is covered by the onscreen keyboard or moves the view back into its normal position when a new field is selected that does not need the view shifted.
    */
    private func moveViewIfNeeded(animated: Bool) {
        // Get the current top location of the keyboard
        guard let keyboardTop = keyboardFrame?.origin.y else {
            return
        }
        
        // Does the view need to be moved in response to the keyboard event?
        if fieldPosition >= keyboardTop {
            // Yes, move the form's view up to expose the field.
            viewMovedToExposeField = true
            let newLocation = CGRect(x: view.frame.minX, y: 0.0 - keyboardOffset, width: view.frame.width, height: view.frame.height)
            if animated {
                UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                    self.view.frame = newLocation
                }.startAnimation()
            } else {
                view.frame = newLocation
            }
        } else if viewMovedToExposeField {
            // Yes, move the view back to its normal location.
            viewMovedToExposeField = false
            let newLocation = CGRect(x: view.frame.minX, y: 0.0, width: view.frame.width, height: view.frame.height)
            // fieldPosition = 0.0
            if animated {
                UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                    self.view.frame = newLocation
                    }.startAnimation()
            } else {
                view.frame = newLocation
            }
        }
    }
    
    /**
     Called before the onscreen keyboard is shown, hidden or its `frame` changes size.
     
     - Parameter notification: Holds information about the keyboard notification event.
    */
    @objc func keyboardEventNotified(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        // Get the current keyboard information and calculate the height of the keyboard from the bottom of the screen.
        keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardOffset = UIScreen.main.bounds.height - keyboardFrame!.origin.y
        
        // Move the view to avoid the keyboard if required.
        moveViewIfNeeded(animated: false)
    }
    
    // MARK: - Override Methods
    /**
     Scans the **Views** and **SubViews** controlled by this `ADBoundViewController` for any controls conforming to the `ADBindable` protocol and monitors any keyboard events.
    */
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Monitor keyboard events
        keyboardNotifications.forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardEventNotified), name: $0, object: nil)
        }
        
        // Scan for any bound elements in this view
        scanView(view)
    }
    
    /**
     Stops monitoring keyboard events.
    */
    override open func viewWillDisappear(_ animated: Bool) {
        
        // Stop monitoring keyboard events
        keyboardNotifications.forEach {
            NotificationCenter.default.removeObserver(self, name: $0, object: nil)
        }
    }
}
