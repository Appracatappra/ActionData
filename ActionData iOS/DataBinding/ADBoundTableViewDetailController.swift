//
//  ADBoundTableViewDetailController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/10/18.
//

import Foundation

/**
 A `ADBoundTableViewDetailController` provides the detail view of data displayed in a Bound Table View and a method to attach it to a data model (any Swift class or structure that conforms to the `Codable` protocol). Any control conforming to the `ADBindable` protocol on any **View** or **SubView** will automatically be populated with the values from the data model based on the `dataPath` property of the control. The `dataPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
 
 By using the `setDataModel` function to set the model and automatically populate the fields, you to not need to create **Actions** or **Outlets** for the individual controls. The `ADBoundTableViewDetailController` will automatically handle the reading and writing of properties for you.
 
 For any `ADBindable` control that is editable, calling the `getDataModel` function will return the values from the controls on the **View** and **SubViews**. These will be written to the field of the data model as specified by the `dataPath` property of the control, as a result, a formula should not be used for the `dataPath` of any field that is readable.
 
 For any field that requires onscreen keyboard support, the `ADBoundTableViewDetailController` will automatically handle keyboard events such as moving fields hidden by the keyboard so they are visible and moving them back after they lose focus. Accessory tools can be automatically added to the keyboard to move between the text entry fields and to close the keyboard based on options for each control. These buttons can be customized using the `prevButtonText`, `prevButtonImage`, `nextButtonText`, `nextButtonImage`, `doneButtonText` and `doneButtonImage` properties of the `ADBoundTableViewDetailController`.
 
 The `ADBoundTextPicker` control has an embedded picker view that will be handled automatically by the `ADBoundTableViewDetailController` in a similar fashion as the onscreen keyboard. If the field is covered by the picker, it will be moved automatically to be shown and moved back when the picker is closed. An accessory toolbar will be added to the picker that can be customized with the `cancelButtonText`, `cancelButtonImage`, `doneButtonText` and `doneButtonImage` properties of the `ADBoundTableViewDetailController`.
 
 If the data being displayed by the `ADBoundTableViewDetailController` can be edited by the user, setting the `liveUpdate` property to `true` will cause the Bound Data Source to retrieve the editing data after each control that is marked `liveUpdate` is edited. Setting the `updateOnClose` property to `true` will cause the Data Source to retrieve the edited data before the view is closed.
 
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
open class ADBoundTableViewDetailController: ADBoundViewController, ADBindingDetailController {
    
    // MARK: - Computed Properties
    /// A reference to the data source that spawned this detail view.
    public var dataSource: ADBindingDataSource?
    
    /// The index path for the source data for this detail view.
    public var indexPath: IndexPath?
    
    /// If `true`, the Data Source will be asked to retrieve the edited data when any control that has its `liveUpdate` property set to `true` finishes editing.
    @IBInspectable public var liveUpdate: Bool = false
    
    /// If `true` the Data Source will be asked to retrieve the edited data before the view is close.
    @IBInspectable public var updateOnClose: Bool = false
    
    /// If `true`, the data source will be forced to reload when this detail view requests the data source to retrieve the edited record. You should only need to set this property to `true` if the Table View is grouping data into sections and the user can edit the section that a given row is in.
    @IBInspectable public var forceReload: Bool = false
    
    // MARK: - Functions
    /**
     Forces the `ADBoundTableViewDetailController` to read the values from any bound control in the `controls` array into the `record` property and write the values back to the bound controls to refresh the view. If the `liveUpdate` property is `true`, the Data Source will be asked to retrieve the edited data.
     */
    override public func refreshDisplay() {
        // Get new values
        getBoundValues()
        
        // Do we support live updating?
        if liveUpdate {
            // Yes, are we bound to a data source?
            if let source = dataSource {
                // Yes, ask the source to retrieve the edits.
                source.retrieveEditedRecord(from: self)
            }
        }
        
        // Update the controls with the new values
        setBoundValues()
    }
    
    /**
     This function is called before the view is closed to handle any required cleanup. If the `updateOnClose` property is `true`, the Data Source will be asked to retrieve the edited data before the view closes.
    */
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Do we to update before closing?
        if updateOnClose {
            // Yes, are we bound to a data source?
            if let source = dataSource {
                // Yes, ask the source to retrieve the edits.
                source.retrieveEditedRecord(from: self)
            }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure the bindings are displayed
        updateBindings()
    }
}
