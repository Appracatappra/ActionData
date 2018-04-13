//
//  ADBoundSlider.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation

/**
 Creates a slider that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the slider's value from.
 
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
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return true}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            print("BINDING ERROR: Unable to set value from data path `\(dataPath)`.")
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