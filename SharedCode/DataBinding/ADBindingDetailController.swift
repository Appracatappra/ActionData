//
//  ADBindingDetailController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/10/18.
//

import Foundation

/**
 Objects conforming to this protocol can be used to display and edit detailed data retrieved from a Bound Data Source (such as `ADBoundTableViewDataSource`).
 */
public protocol ADBindingDetailController {
    
    /// A reference to the data source that spawned this detail view.
    var dataSource: ADBindingDataSource? {get set}
    
    /// The index path for the source data for this detail view.
    var indexPath: IndexPath? {get set}
    
    /// If `true`, the data source will be forced to reload when this detail view requests the data source to retrieve the edited record. You should only need to set this property to `true` if the Table View is grouping data into sections and the user can edit the section that a given row is in.
    var forceReload: Bool {get set}
    
}
