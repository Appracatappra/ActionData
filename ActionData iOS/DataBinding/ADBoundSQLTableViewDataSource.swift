//
//  ADBoundSQLTableViewDataSource.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/23/18.
//

import Foundation

open class ADBoundSQLTableViewDataSource: NSObject, UITableViewDataSource, ADBindingDataSource {
    
    // MARK: - Private Variables
    /// If `true`, the data source is currently providing filtered results based on a user search.
    private var insideOfSearch = false
    
    /// Saves the last search term.
    private var lastSearchTerm = ""
    
    /// Saves the last search scope.
    private var lastSearchScope = ""
    
    // MARK: - Computed Properties
    public var dataProvider: ADDataProvider?
    
    public func reloadData() {
        <#code#>
    }
    
    public func filterData(onSearchText text: String, scope: String) {
        <#code#>
    }
    
    public func retrieveEditedRecord(from entity: ADBindingController & ADBindingDetailController) {
        <#code#>
    }
    
    public func retrieveRecord(for indexPath: IndexPath) -> ADRecord {
        <#code#>
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
