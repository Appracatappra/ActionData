//
//  ADBoundSegmentedControl.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a segmented control that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to select the segment from. Use the `byTitle` propert to decide if the segment is selected by title or integer position.
 
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
 
 // Bind the segemented control to the type field
 mySegment.dataPath = "type"
 ```
 */
@IBDesignable open class ADBoundSegmentedControl: UISegmentedControl, ADBindable {
    
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
     
     // Bind the segemented control to the type field
     mySegment.dataPath = "type"
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
     
     // Bind the segmented control to the enabled field
     mySegmentedControl.enabledPath = "enabled"
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
     mySegmentedControl.hiddenPath = "quantity > 0"
     ```
     
     - remark: The case and name of the field specified in the `hiddenPath` property must match the case and name from the data model bound to the `ADBoundViewController`. Optionally, the value can be a forumla using a subset of the SQL syntax.
     */
    @IBInspectable public var hiddenPath: String = ""
    
    /// If `true` this segmented control causes the parent `ADBoundViewController` to update the form as the value changes.
    @IBInspectable public var liveUpdate: Bool = false
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
    public weak var controller: ADBoundViewController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /// If `true` the segment is selected by its title, else it is selected by its integer position.
    @IBInspectable public var byTitle: Bool = true
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return true}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Watch value change
        addTarget(self, action: #selector(controlValueChanged(sender:)), for: UIControlEvents.valueChanged)
    }
    
    // MARK: - Functions
    /**
     Handles the value of the control being changed.
     
     - Parameter sender: The control that was changed.
     */
    @objc internal func controlValueChanged(sender : UISegmentedControl) {
        // Is the control live updating?
        if liveUpdate {
            if let bindEngine = controller {
                bindEngine.refreshDisplay()
            }
        }
    }
    
    /**
     Sets the selected segment based on the given value and the state of the `byTitle` property. If `byTitle` is `true`, the segment matching the value will be selected, else the value will be used as the integer position of the segment to select.
     
     - Parameter value: The value to set the label to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            if byTitle {
                // Force the value to a string and display it
                var title = try ADUtilities.cast(value, to: .textType) as! String
                title = title.lowercased()
                
                // Find the title and select it
                for index in 1...numberOfSegments {
                    let segment = titleForSegment(at: index - 1)?.lowercased()
                    if segment == title {
                        selectedSegmentIndex = index - 1
                    }
                }
            } else {
                // Force the value to an integer and display it
                let index = try ADUtilities.cast(value, to: .integerType) as! Int
                selectedSegmentIndex = index
            }
        } catch {
            print("BINDING ERROR: Unable to set segmented control value from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set segmented control enabled state from data path `\(dataPath)`.")
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
            print("BINDING ERROR: Unable to set segmented control hidden state from data path `\(dataPath)`.")
        }
    }
    
    /**
     Returns the value of the selected segment based on the state of the `byTitle` property. If `byTitle` is `true`, the title is returned else the integer position of the selected segment is returned.
     
     - Returns: The title or the position of the selected segment based on the `byTitle` property.
     */
    public func getValue() -> Any {
        // By title?
        if byTitle {
            if let title = titleForSegment(at: selectedSegmentIndex) {
                return title.lowercased()
            } else {
                return ""
            }
        } else {
            return selectedSegmentIndex
        }
    }
    
}
