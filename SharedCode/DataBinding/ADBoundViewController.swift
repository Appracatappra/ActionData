//
//  ADBoundViewController.swift
//  ActionData
//
//  Created by Kevin Mullins on 4/12/18.
//

import Foundation

/**
 A `ADBoundViewController` provides a method to attach a data model (any Swift class or structure that conforms to the `Codable` protocol) and it will automatically populate any control conforming to the `ADBindable` protocol on any View or SubView with the values from the data model based on the `dataPath` property of the control. The `dataPath` must match the name and case of a field on the attached data model. Use the `setDataModel` function to set the model and automatically populate the fields.
 
 For any `ADBindable` control that is editable, calling the `getDataModel` function will return the values from the controls on the View and SubViews. These will be written to the field of the data model as specified by the `dataPath` property of the control.
 
 Using a `ADBoundViewController`, you to not need to create actions or outlets for the individual controls. The `ADBoundViewController` will automatically handle the reading and writing of properties for you.
 
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
open class ADBoundViewController: UIViewController {
    
    // MARK: - Private Variables
    /// The internal encoder used to convert the data model into a `ADRecord` for working with the bounds controls.
    private let encoder = ADSQLEncoder()
    
    /// The internal decoder used to convert the `ADRecord` back into a data model with the values from the bound controls.
    private let decoder = ADSQLDecoder()
    
    /// An array of all bound controls discovered in the View and Subview controlled by this `ADBoundViewController`.
    private var controls: [ADBindable] = []
    
    // MARK: - Computed Properties
    /**
     A `ADRecord` representing the attached data model as a set of key/value pairs where the key is the name of the field that the value was read from or is writtne to.
    */
    public var record: ADRecord = [:]
    
    // MARK: - Initializers
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Functions
    /**
     Attaches the given data model (any Swift class or structure conforming to the `Codeable` protocol) to the `ADBoundViewController` populating the `record` property and any control conforming to the `ADBindable` protocol on any View or SubView.
     
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
     Reads the values from any editable control conforming to the `ADBindable` protocol into the given data model (any Swift class or structure conforming to the `Codeable` protocol).
     
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
     Forces the `ADBoundViewController` to update the values of any control conforming to the `ADBindable` protocol on any View or SubView controlled by this `ADBoundViewController` with the values from the `record` property.
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
     Scans the View and SubViews controlled by this `ADBoundViewController` for any control conforming to the `ADBindable` protocol and collects them in the `controls` array.
     
     - Parameter parentView: The View to scan for controls.
    */
    private func scanView(_ parentView: UIView) {
        // Scan all subviews
        for view in parentView.subviews {
            if let boundControl = view as? ADBindable {
                // Add the control to the collection of known controls
                controls.append(boundControl)
                
                // Check for any sub controls
                scanView(view)
            }
        }
    }
    
    /**
     Takes the values from the `record` property and writes them to any control in the `controls` array where the `dataPath` matches the name of a key from the `record` dictionary.
    */
    private func setBoundValues() {
        // Process all controls
        for control in controls {
            // Does the dictionary contain the key?
            if let data = record[control.dataPath] {
                control.setValue(data)
            }
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
    
    // MARK: - Override Methods
    /**
     Scans the View and SubView controlled by this `ADBoundViewController` for any controls conforming to the `ADBindable` protocol.
    */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Scan for any bound elements in this view
        scanView(view)
    }
    
}
