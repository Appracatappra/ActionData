//
//  ADBoundTableViewController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/3/18.
//

import Foundation

/**
 The `ADBoundTableViewController` includes several convenience features when working with a `ADBoundTableView` such as return a pre-cast version of the controlled table view.
 */
open class ADBoundTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Private Variables
    private let refresher = UIRefreshControl()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var tableViewLoaded = false
    
    // MARK: - Public Properties
    /// If the table view being controlled by this view controller is a `ADBoundTableView` return it, else return `nil`.
    public var boundTableView: ADBoundTableView? {
        // Try to return the bound controller
        return tableView as? ADBoundTableView
    }
    
    /**
     If `true`, a Refresh Control will be added to the table view that will allow the user to pull to refresh the data source. You should override the `refreshBoundData` function and call the `reloadData` function on your `ADBoundTableViewDataSource` in response.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundTableViewDataSource<Category>()
     
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
    
    @IBInspectable public var searchPlaceholderText: String = "" {
        didSet {
            // Set placeholder text
            searchController.searchBar.placeholder = searchPlaceholderText
        }
    }
    
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
    
    @IBInspectable public var searchFirstOptionAll: Bool = false
    
    public var searchBarIsEmpty: Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
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
        
        // The view has loaded
        tableViewLoaded = true
    }
    
    /**
     You should override this function and provide the method to refresh your data source when the user pulls down to refresh if the `pullToRefresh` property is `true`. If you don't override this function, it will automatically attempt to reload the data source attached to the bound table view.
     
     ## Example:
     ```swift
     // Create storage for the table's data
     let info = ADBoundTableViewDataSource<Category>()
     
     override func refreshBoundData() {
         // Refresh the data source and stop refresh
         info.reloadData()
         finishedRefreshingData()
     }
     ```
    */
    @objc open func refreshBoundData() {
        // Can we access the data source?
        if let dataSource = boundTableView?.dataSource as? ADBindingDataSource {
            // Any search term?
            if searchBarIsEmpty {
                // No, display all data
                dataSource.reloadData()
            } else {
                // Get search text
                if let text = searchController.searchBar.text {
                    // Ask data source to filter on text
                    dataSource.filterData(onSearchText: text, scope: "")
                }
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
     let info = ADBoundTableViewDataSource<Category>()
     
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
    
    // MARK: - UISearchResultsUpdating
    public func updateSearchResults(for searchController: UISearchController) {
        // Can we access the data source?
        if let dataSource = boundTableView?.dataSource as? ADBindingDataSource {
            // Any search term?
            if searchBarIsEmpty {
                // No, display all data
                dataSource.reloadData()
            } else {
                // Get search text
                if let text = searchController.searchBar.text {
                    // Ask data source to filter on text
                    dataSource.filterData(onSearchText: text, scope: searchScopeSelected)
                }
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Can we access the data source?
        if let dataSource = boundTableView?.dataSource as? ADBindingDataSource {
            // Get the search text
            let text = searchController.searchBar.text ?? ""
            
            // Ask data source to filter on text
            dataSource.filterData(onSearchText: text, scope: searchScopeSelected)
        }
    }
}
