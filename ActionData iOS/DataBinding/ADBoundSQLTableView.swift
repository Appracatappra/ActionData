//
//  ADBoundSQLTableView.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/23/18.
//

import Foundation

open class ADBoundSQLTableView: UITableView {
    
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
    
    /// If `true` and the Table View is in the edit mode, the user can delete rows from the table.
    @IBInspectable public var canDeleteRows: Bool = false
    
    /**
     Defines the unique identifier used to recognize a individual row of data read from the data source. For SQLite data sources this will typically be the unique `ROWID` that is automatically created for each row of the table.
     
     ## Example
     ```swift
     // Set the unique identifier
     boundTableView.uniqueRowID = "id"
     ```
     
     - Remark: This property _must_ be set for the `canDeleteRows` option to work correctly.
    */
    @IBInspectable public var uniqueRowID: String = ""
    
    /// If `true`, the SQL statement built to extract the data used to populate this table will include the `DISTINCT` statement to limit the results returned to distinct results.
    @IBInspectable public var distinctRecords: Bool = false
    
    /**
     Defines the fields that will read from the data source used to populate this table. The value of this property takes the form of a SQL SELECT statement (minus the `SELECT` keyword). The default value is `*` to read all fields.
    */
    @IBInspectable public var selectClause: String = "*"
    
    /**
     Defines the data source tables that data will be read from. The value of this property takes the form of a SQL FROM statement (minus the `FROM` keyword).
    */
    @IBInspectable public var fromClause: String = ""
    
    /**
     Defines a filter used to limit the records returned from the data source. The value of this property takes the form of a SQL WHERE statement (minus the `WHERE` keyword).
     */
    @IBInspectable public var whereClause: String = ""
    
    /**
     Defines a filter used to sort the records returned from the data source. The value of this property takes the form of a SQL ORDER BY statement (minus the `ORDER BY` keyword).
     */
    @IBInspectable public var orderByClause: String = ""
    
    // MARK: - Initializers
    /// Initializes a new instance of the `ADBoundTableView`.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Finish initialization
        initialize()
    }
    
    /// Initializes a new instance of the `ADBoundTableView`.
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        // Finish initialization
        initialize()
    }
    
    /// Finish the initialization process.
    private func initialize(){
        
    }
}
