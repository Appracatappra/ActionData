//
//  ADBoundWebView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 4/13/18.
//

import Foundation
import WebKit

/**
 Creates a web view that can be bound to a value from a data model that conforms to the `Codable` protocol when placed on a `ADBoundViewController` view. Use the `dataPath` property to specify the field from the bound data model to use as the URL or the HTML data to display in the web view. Use the `containsHTML` property to decide if the `dataPath` contains a `URL` or `HTML` data.
 
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
     var url = "http://google.com"
 
     required init() {
 
     }
 }
 
 // Bind the web view to the url field
 myWebView.dataPath = "url"
 ```
 */
@IBDesignable open class ADBoundWebView: WKWebView, ADBindable {
    
    // MARK: - Private Variables
    /// Contains the URL or the raw HTML being displayed
    var backingData = ""
    
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
         var url = "http://google.com"
     
         required init() {
     
         }
     }
     
     // Bind the web view to the url field
     myWebView.dataPath = "url"
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
    
    /// If `true` the `dataPath` property contains raw HTML that needs to be displayed, if `false` the `dataPath` contains a URL to display.
    @IBInspectable public var containsHTML: Bool = false
    
    /// Returns `true` if the value of the control can be edited by the user, else returns `false`.
    public var isMutable: Bool {
        get {return false}
    }
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
     Sets the value of the label from the given value. If the value is an `Int` or `Float` it will be converted to a string. If the value is a `Bool` it will be converted to the string values of `true` or `false`.
     
     - Parameter value: The value to set the label to.
     */
    public func setValue(_ value: Any) {
        // Try to convert to needed value
        do {
            // Force the value to a string and display it
            let data = try ADUtilities.cast(value, to: .textType) as! String
            backingData = data
            if containsHTML {
                // Display the raw HTML
                loadHTMLString(data, baseURL: nil)
            } else {
                // Display the given URL
                let path = URL(string: data)
                if let url = path {
                    let request = URLRequest(url: url)
                    load(request)
                }
            }
        } catch {
            print("BINDING ERROR: Unable to set value from data path `\(dataPath)`.")
        }
    }
    
    /**
     Returns the backing data for the web view as either the URL or the raw HTML being displayed.
     
     - Returns: The backing data for the web view as a `String`.
     */
    public func getValue() -> Any {
        return backingData
    }
    
}
