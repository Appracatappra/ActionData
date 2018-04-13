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
    
    /// If `true` the segment is selected by its title, else it is selected by its integer position.
    @IBInspectable public var byTitle: Bool = true
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return true}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            print("BINDING ERROR: Unable to set value from data path `\(dataPath)`.")
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
