//
//  ADImageView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation
import ActionUtilities

/**
 Creates an image view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to populate the image view from.
 
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
 
 // Bind the image view to the icon field
 myImage.dataPath = "icon"
 ```
 */
@IBDesignable open class ADBoundImageView: UIImageView, ADBindable {
    
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
     
     // Bind the image view to the icon field
     myLabel.dataPath = "icon"
     ```
     
     - remark: The case and name of the field specified in the `dataPath` property must match the case and name from the data model bound to the `ADBoundViewController`.
     */
    @IBInspectable public var dataPath: String = ""
    
    /// Provides a link to the `ADBoundViewController` that the control is bound to.
    public weak var controller: ADBoundViewController?
    
    /**
     Provides a unique ID that is assigned to the control when it is bound to a `ADBoundViewController`.
     - Remark: You should never set or change this number yourself, this value will be managed by the `ADBoundViewController` and is used to handle form and keyboard events.
     */
    public var formID: Int = -1
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return false}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Sets the value of the image view from the given value. If the value is `String`, this function assumes its a Base 64 encoded image and will attempt to decode it.
     
     - Parameter value: The value to set the image to.
     */
    public func setValue(_ value: Any) {
        // Have we been passed a raw image?
        if let img = value as? UIImage {
            image = img
        } else if let data = value as? String {
            // Set the image from a base 64 encoded string
            image = data.uiImage
        } else {
            print("BINDING ERROR: Data path `\(dataPath)` is not a valid type to set an image view from. It must be a `UIImage` or `String` containing a base 64 encoded image.")
        }
    }
    
    /**
     Returns the value of the image view as a base 64 encoded string.
     
     - Returns: The value of the image view as a `String`.
     */
    public func getValue() -> Any {
        if image == nil {
            return ""
        } else {
            // Convert the image to a string
            return image!.toString()
        }
    }
    
}
