//
//  ADBoundTableView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/4/18.
//

import Foundation

/**
 The `ADBoundTableView` works with a `ADBoundTableViewDataSource` and a `ADBoundTableViewCell` to provide a data bound table of items based on a give collection of data model objects (any Swift class or structure that conforms to the `Codable` protocol). Any control conforming to the `ADBindable` protocol on any **View** or **SubView** (in the `ADBoundTableViewCell`) will automatically be populated with the values from the data model based on the `dataPath` property of the control. The `dataPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
 
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
 
 // Create storage for the table's data
 let info = ADBoundTableViewDataSource<Category>()
 
 // Add data to the table's data source
 for n in 1...10 {
     let category = Category(name: "Category \(n)", description: "Description for category \(n).")
     info.data.append(category)
 }
 
 // Attach to table
 info.parentTableView = boundTableView
 ```
 */
open class ADBoundTableView: UITableView {
    
    // MARK: - Computed Properties
    /**
     Provides the **Identifier** of a Table View Cell (`ADBoundTableViewCell`) that will be used to display the individual rows of the table. Your storyboard must define a Table Cell Prototype with the given **Identifier** or an error will be thrown. The `cellIdPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
     
     ##Example
     ```swift
     // Set the cell prototype based on the type of data being displayed.
     boundTableView.cellIdPath = """
        CASE use
        WHEN 'local' THEN 'localCell'
        WHEN 'web' THEN 'webCell'
        ELSE 'boundCell' END
     """
     ```
    */
    @IBInspectable public var cellIdPath: String = "boundCell"
    
    /**
     If `true` the `ADBoundTableViewDataSource` will attempt to group the data into section based on the value of the `groupPath` property, else the data will not be grouped into sections. 
    */
    @IBInspectable public var groupData: Bool = false
    
    /**
     Provides the field that the data should be grouped on when the `groupData` property is `true`. The `groupPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
     
     ## Example
     ```swift
     // Set the path to group data on
     boundTableView.groupData = true
     boundTableView.groupPath = "use"
     ```
    */
    @IBInspectable public var groupPath: String = ""
    
    /**
     Specifies the field that provides the grouped data section title when the `groupData` property is `true`. The `groupTitlePath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
     
     ## Example
     ```swift
     // Set the path to group data on
     boundTableView.groupData = true
     boundTableView.groupTitlePath = """
         CASE use
         WHEN 'local' THEN 'Local Categories'
         WHEN 'web' THEN 'Web Categories'
         ELSE 'Other Categories' END
         """
     ```
     */
    @IBInspectable public var groupTitlePath: String = ""
    
    /**
     Specifies the field that provides the grouped data section footer title when the `groupData` property is `true`. The `groupFooterPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
     
     ## Example
     ```swift
         // Set the path to group data on
         boundTableView.groupData = true
         boundTableView.groupFooterPath = "'Includes all item in the ' + use + ' category.'"
     ```
     */
    @IBInspectable public var groupFooterPath: String = ""
    
    /// Specifies the field from the bound data object to search on. The `searchPath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
    @IBInspectable public var searchPath: String = ""
    
    /// Specifies the field from the bound data object to search scope on. The `searchScopePath` must match the name and case of a field on the attached data model or be a formula using a SQL like syntax.
    @IBInspectable public var searchScopePath: String = ""
    
    /// Specifies the optional title shown over the search results for this table. `$0` in the text will be replaced with the total number of items in the data source. `$1` in the text will be replaced with the total number of items matching to search term.
    @IBInspectable public var searchTitle: String = ""
    
    /// Specifies the optional footer shown at the bottom of the search results for this table. `$0` in the text will be replaced with the total number of items in the data source. `$1` in the text will be replaced with the total number of items matching to search term.
    @IBInspectable public var searchFooter: String = ""
    
    /// If `true` and the Table View is in the edit mode, the user can drag rows to reorder them.
    @IBInspectable public var canReorderRows: Bool = false
    
    /// If `true` and the Table View is in the edit mode, the user can delete rows from the table.
    @IBInspectable public var canDeleteRows: Bool = false
    
    // MARK: - Initializers
    /// Initializes a new instance of the `ADBoundTableView`.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Finish initialization
        initialize()
    }
    
    /// Initializes a new instance of the `ADBoundTableView`.
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        // Finish initialization
        initialize()
    }
    
    /// Finish the initialization process.
    private func initialize(){
        
    }
    
}
