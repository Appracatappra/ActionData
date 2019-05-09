//
//  ADBoundSQLTableViewCell.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/23/18.
//

import Foundation

open class ADBoundSQLTableViewCell: UITableViewCell, ADBindingController, ADBindingDetailController {
    
    // MARK: - Private Variables
    /// The internal encoder used to convert the data model into a `ADRecord` for working with the bounds controls.
    private let encoder = ADSQLEncoder()
    
    /// The internal decoder used to convert the `ADRecord` back into a data model with the values from the bound controls.
    private let decoder = ADSQLDecoder()
    
    /// An array of all bound controls discovered in the View and Subview controlled by this `ADBoundViewController`.
    private var controls: [ADBindable] = []
    
    // MARK: - Computed Properties
    /// A reference to the parent table view controller for this cell.
    public weak var controller: UITableViewController?
    
    /// A reference to the data source that spawned this cell.
    public var dataSource: ADBindingDataSource?
    
    /// The index path for the cell.
    public var indexPath: IndexPath?
    
    /// An ID that uniquely identifies the record behind the data for this cell in the data source. For example, a SQLite database might use the `ROWID` here.
    public var rowIdentifier: Any?
    
    /**
     A `ADRecord` representing the attached data model as a set of key/value pairs where the key is the name of the field that the value was read from or is writtne to. In between `setDataModel` and `getDataModel` function calls, use this property to interact with the values from the data model.
     */
    public var record: ADRecord = [:]
    
    /**
     If `true`, this cell supports inline editing and will report any changes back to the data source so that they can be read back into the parent object.
     
     - Remark: Any editable control (that conforms to the `ADBinding` protocol) **must** have its `liveUpdate` property set to `true` for this feature to work correctly.
     */
    @IBInspectable public var inlineEdit: Bool = false
    
    /// If `true` and the `inlineEdit` is `true`, the data source will be forced to reload the data after an inline edit has completed. You should only need to set this property to `true` if the Table View is grouping data into sections and the user can edit the section that a given row is in inline.
    @IBInspectable public var forceReload: Bool = false
    
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
        
        // Finish initialization
        initialize()
    }
    
    /// Initializes a new instance of the `ADBoundViewController`.
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Finish initialization
        initialize()
    }
    
    /// Finish the initialization process.
    private func initialize(){
        // Find all subviews
        scanView(contentView, top: 0.0)
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
        if let tableController = controller {
            tableController.present(alert, animated: true)
        }
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
        
        // Do we support inline editing?
        if inlineEdit {
            // Yes, are we bound to a data source?
            if let source = dataSource {
                // Yes, ask the source to retrieve the edits
                source.retrieveEditedRecord(from: self)
            }
        }
        
        // Update the controls with the new values
        setBoundValues()
    }
    
    /**
     Scans the **View** and **SubViews** controlled by this `ADBoundViewController` for any control conforming to the `ADBindable` protocol and collects them in the `controls` array.
     
     - Parameters:
     - parentView: The View to scan for controls.
     - top: The top location of the parent, containing view.
     */
    private func scanView(_ parentView: UIView, top: Float) {
        // Scan all subviews
        for view in parentView.subviews {
            if var boundControl = view as? ADBindable {
                // Attach control to this controller
                boundControl.controller = self
                
                // Assign a form ID to the control
                boundControl.formID = controls.count
                
                // Set the top offset
                boundControl.topOfFormOffset = top
                
                // Add the control to the collection of known controls
                controls.append(boundControl)
            }
            
            // Calculate top location
            let viewTop = top + Float(parentView.frame.origin.y)
            
            // Check for any sub controls
            scanView(view, top: viewTop)
        }
    }
    
    /**
     Takes the values from the `record` property and writes them to any control in the `controls` array where the `dataPath` matches the name of a key from the `record` dictionary.
     */
    private func setBoundValues() {
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
    private func getBoundValues() {
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
     
     - Parameters:
     - fieldFrame: The `GCRect` of the text field or view that has just gained focus.
     - topOffset: The offset to the top of the containing form for bound controls that are inside of a Sub View.
     */
    public func moveViewToExposeField(withFrame fieldFrame: CGRect, andOffset topOffset: Float) {
        
        // TODO: Fix this
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
}
