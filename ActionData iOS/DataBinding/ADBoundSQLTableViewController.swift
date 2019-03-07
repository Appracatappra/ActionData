//
//  ADBoundSQLTableViewController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/23/18.
//

import Foundation

open class ADBoundSQLTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Private Variables
    /// A private instance of the pull-to-refresh control.
    private let refresher = UIRefreshControl()
    
    /// A private instance of the search controller.
    private let searchController = UISearchController(searchResultsController: nil)
    
    /// `true` if the controlled Table View has already been loaded into memory, else `false`.
    private var tableViewLoaded = false
    
    /// Holds the last cell selected from the table view or `nil` if no cell is selected.
    private var lastSelectedIndexPath: IndexPath? = nil
    
    /// Holds the data for a new item being added to the table.
    private var newItemRecord: ADRecord = [:]
    
    // MARK: - Computed Properties
    /// If the table view being controlled by this view controller is a `ADBoundSQLTableView` return it, else return `nil`.
    public var boundTableView: ADBoundSQLTableView? {
        // Try to return the bound table
        return tableView as? ADBoundSQLTableView
    }
    
    /// If the table view being controlled by this view controller is a `ADBoundTableView`, gets or sets the Data Source for the table's data and attaches it to the Table View.
    public var boundDataSource: ADBoundSQLTableViewDataSource = ADBoundSQLTableViewDataSource()
    
    /**
     If `true`, a Refresh Control will be added to the table view that will allow the user to pull to refresh the data source. You should override the `refreshBoundData` function and call the `reloadData` function on your `ADBoundSQLTableViewDataSource` in response.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundSQLTableViewDataSource()
     
     override func refreshBoundData() {
         // Refresh the data source and stop refresh
         info.reloadData()
         finishedRefreshingData()
     }
     ```
     */
    @IBInspectable public var pullToRefresh: Bool = false {
        didSet {
            // Has the table view already been loaded?
            if tableViewLoaded {
                // Yes, add or remove the pull to refresh control
                if pullToRefresh {
                    refreshControl = refresher
                } else {
                    refreshControl = nil
                }
            }
        }
    }
    
    /// When the `pullToRefresh` property is `true`, sets the title that is displayed on the Refresh Control.
    @IBInspectable public var pullToRefreshTitle: String = "" {
        didSet {
            // Set the title of the refresh control
            refresher.attributedTitle = NSAttributedString(string: pullToRefreshTitle)
        }
    }
    
    /// When the `pullToRefresh` property is `true`, sets the tint color of the Refresh Control.
    @IBInspectable public var pullToRefreshTint: UIColor = UIColor.black {
        didSet {
            // Set the tint color of the Refresh Control
            refresher.tintColor = pullToRefreshTint
        }
    }
    
    /**
     If `true`, the table will automatically display and handle the search controller to allow the user to search for data. The following properties of the `ADBoundSQLTableView` control the search process and results:
     
     * `searchField` - Defines the field that will be used for filtering results. This field must contain the users search text to be displayed in the results list. Searching in non-case sensetive.
     * `searchScopeField` - In addition to the search text, the results can be limited to a give scope (if the `searchScopeBar` property of the `ADBoundSQLTableViewController` is `true`). This specifies the field that is used to match the scope. Scope matching is non-case sensetive.
     */
    @IBInspectable public var searchTable: Bool = false {
        didSet {
            // Is the table view loaded?
            if tableViewLoaded {
                if searchTable {
                    // Attach search controller
                    navigationItem.searchController = searchController
                } else {
                    // Remove search controller
                    navigationItem.searchController = nil
                }
            }
        }
    }
    
    /**
     If the `searchScopeBar` property of the `ADBoundSQLTableViewController` is `true`, this text will be the placeholder that is displayed in the Search Bar before the user enters any text.
     */
    @IBInspectable public var searchPlaceholderText: String = "" {
        didSet {
            // Set placeholder text
            searchController.searchBar.placeholder = searchPlaceholderText
        }
    }
    
    /**
     If the `searchScopeBar` property of the `ADBoundSQLTableViewController` is `true` and this property is `true`, a scope bar will be displayed allowing the user to limit results to a given scope in addition to the search text entered. The following properties of the `ADBoundSQLTableView` control the search process and results:
     
     * `searchField` - Defines the field that will be used for filtering results. This field must contain the users search text to be displayed in the results list. Searching in non-case sensetive.
     * `searchScopeField` - This specifies the field that is used to match the scope. Scope matching is non-case sensetive.
     
     The `searchScopeOptions` of the `ADBoundSQLTableViewController` provides a comma-separated list of values that will be used to present the options.
     */
    @IBInspectable public var searchScopeBar: Bool = false {
        didSet {
            // Is scope bar enabled?
            if searchScopeBar {
                // Yes, get array of titles
                searchController.searchBar.scopeButtonTitles = searchScopeOptions.components(separatedBy: ",")
                searchController.searchBar.delegate = self
            } else {
                // No, clear titles
                searchController.searchBar.scopeButtonTitles = []
                searchController.searchBar.delegate = nil
            }
        }
    }
    
    /**
     If the `searchScopeBar` and `searchScopeBar` properties of the `ADBoundSQLTableViewController` are `true`, this property provides a comma-separated list of values that will be used to generate the Scope Buttons in the Scope Bar.
     */
    @IBInspectable public var searchScopeOptions: String = "" {
        didSet {
            // Is scope bar enabled?
            if searchScopeBar {
                // Yes, get array of titles
                searchController.searchBar.scopeButtonTitles = searchScopeOptions.components(separatedBy: ",")
            } else {
                // No, clear titles
                searchController.searchBar.scopeButtonTitles = []
            }
        }
    }
    
    /**
     If the `searchScopeBar`, `searchScopeBar` and `searchFirstOptionAll` properties of the `ADBoundSQLTableViewController` are `true`, the first option in the Scope Bar (as populated from the `searchScopeOptions` property) will be treated as an **Any** or **All** property and will include all scopes in the search results.
     */
    @IBInspectable public var searchFirstOptionAll: Bool = false
    
    /// If this table view displays a detail view when a table cell is selected, this property specifies the Identifier of the segue used to display the detail view. The default value is `showDetail`.
    @IBInspectable public var detailSegueIdentifier: String = "showDetail"
    
    /// If the user can add new items to the table, this property specifies the segue that will be called to display the detailed view when a new item is created.
    @IBInspectable public var addItemSegueIedntifier: String = ""
    
    /// Returns `true` if the Search Bar is empty, else returns `false`
    public var searchBarIsEmpty: Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /// Returns the text of the currently selected Scope Bar button. If the `searchFirstOptionAll` and the first button is selected, the empty string is returned (`""`).
    public var searchScopeSelected: String {
        // Is the scope bar being used?
        if searchScopeBar {
            // Is the first option all?
            if searchFirstOptionAll && searchController.searchBar.selectedScopeButtonIndex == 0 {
                // Yes, no scope
                return ""
            } else {
                // No, return requested scope
                return searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex] ?? ""
            }
        } else {
            // No scope.
            return ""
        }
    }
    
    // MARK: - Initializers
    /// Initializes a new instance of the `ADBoundViewController`.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Finish initialization
        initialize()
    }
    
    /// Finish the initialization process.
    private func initialize(){
        // Attach refresh control to the refresh action
        refresher.addTarget(self, action: #selector(refreshBoundData), for: .valueChanged)
        
        // Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    // MARK: - Functions
    /**
     If you are going to add a new item to the table and you need to display the detail view when the item is added, call this method to prepare the controller to display the details. You must specify the segue used to display the Detail View in the `addItemSegueIedntifier` property before calling this function. When the data model has been prepared, the Detail View will automatically be displayed.
     
     ## Example:
     ```swift
     // Create a new instance and pass it to the Table Controller.
     let category = Category(name: "Untitled", description: "New category.")
     do {
        try prepareToAddNewItem(category)
     } catch {
        print("Failed to set data model")
     }
     ```
     
     - Parameter value: A Swift Class or Struct conforming to the `Encodable` protocol.
     */
    public func prepareToAddNewItem<T:Encodable>(_ value: T) throws {
        let encoder = ADSQLEncoder()
        let model = try encoder.encode(value)
        if let data = model as? ADRecord {
            // Save model data
            newItemRecord = data
            
            // Was a segue defined?
            if addItemSegueIedntifier == "" {
                // No, report issue to developer
                print("Unable to open Detail View for new item because the `addItemSegueIedntifier` has not been defined.")
            } else {
                // Display detail view
                performSegue(withIdentifier: addItemSegueIedntifier, sender: self)
            }
        }
    }
    
    /**
     Handles the Table View initially being loaded into memory.
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Using pull to refresh?
        if pullToRefresh {
            // Attach reload controller
            refreshControl = refresher
        }
        
        // Using search?
        if searchTable {
            // Attach search controller
            navigationItem.searchController = searchController
        }
        
        // TODO: Attach Data Source
        
        // The view has loaded
        tableViewLoaded = true
    }
    
    /**
     You should override this function and provide the method to refresh your data source when the user pulls down to refresh if the `pullToRefresh` property is `true`. If you don't override this function, it will automatically attempt to reload the data source attached to the bound table view.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundSQLTableViewDataSource()
     
     override func refreshBoundData() {
         // Refresh the data source and stop refresh
         info.reloadData()
         finishedRefreshingData()
     }
     ```
     */
    @objc open func refreshBoundData() {
        // Any search term?
        if searchBarIsEmpty {
            // No, display all data
            boundDataSource.reloadData()
        } else {
            // Get search text
            if let text = searchController.searchBar.text {
                // Ask data source to filter on text
                boundDataSource.filterData(onSearchText: text, scope: "")
            }
        }
        
        // Finish refresh
        finishedRefreshingData()
    }
    
    /**
     Call this function to end the refresh cycle when the user pulls down to refresh the data source and the `pullToRefresh` property is `true`.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundSQLTableViewDataSource()
     
     override func refreshBoundData() {
         // Refresh the data source and stop refresh
         info.reloadData()
         finishedRefreshingData()
     }
     ```
     */
    open func finishedRefreshingData() {
        // Tell refresh control we are done
        refresher.endRefreshing()
    }
    
    /**
     Prepares for a segure to take place. If the destination is a `ADBoundSQLTableViewDetailController` and the Segue Identifier matches the `detailSegueIdentifier` property, the Detail View will be loaded with the data from the last table cell selected. If the Segue Identifier matches the `addItemSegueIedntifier` property, the data from the last `prepareToAddNewItem` function call will be used to populate the Detail View.
     
     - Parameters:
     - segue: The segue that is about to be preformed.
     - sender: The object that is the source of the segue launch.
     */
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the segue ID.
        if let identifier = segue.identifier {
            // Take action based on the ID.
            if identifier == detailSegueIdentifier {
                // Heading towards a detail view controller?
                if let detailView = segue.destination as? ADBoundTableViewDetailController {
                    // Get index
                    if let indexPath = lastSelectedIndexPath {
                        // Configure detail view.
                        detailView.dataSource = boundDataSource
                        detailView.indexPath = indexPath
                        detailView.record = boundDataSource.retrieveRecord(for: indexPath)
                    }
                }
            } else if identifier == addItemSegueIedntifier {
                // Heading towards a detail view controller?
                if let detailView = segue.destination as? ADBoundTableViewDetailController {
                    // Configure detail view.
                    detailView.dataSource = boundDataSource
                    detailView.indexPath = nil
                    detailView.record = newItemRecord
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    /**
     Traks when a new cell will be selected in the table and stores this cell being selected so it can be used to populate the detail view.
     
     - Parameters:
     - tableView: The parent Table View.
     - indexPath: The path to the cell being selected.
     
     - Returns: The path to the cell that should be selected or `nil` if no cell should be selected.
     */
    open override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        // Save the path to the cell being selected.
        lastSelectedIndexPath = indexPath
        
        // Don't alter selection
        return indexPath
    }
    
    // MARK: - UISearchResultsUpdating
    /**
     Handles updating the search results when the user enters text into the Search Bar.
     
     - Parameter searchController: The parent controller performing the search.
     */
    public func updateSearchResults(for searchController: UISearchController) {
        // Any search term?
        if searchBarIsEmpty {
            // No, display all data
            boundDataSource.reloadData()
        } else {
            // Get search text
            if let text = searchController.searchBar.text {
                // Ask data source to filter on text
                boundDataSource.filterData(onSearchText: text, scope: searchScopeSelected)
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    /**
     Handles the user selecting a new button from the Scope Bar.
     
     - Parameters:
     - searchBar: The parent Search Bar handling the search process.
     - selectedScope: The new scope selected by the user.
     */
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Get the search text
        let text = searchController.searchBar.text ?? ""
        
        // Ask data source to filter on text
        boundDataSource.filterData(onSearchText: text, scope: searchScopeSelected)
    }
}
