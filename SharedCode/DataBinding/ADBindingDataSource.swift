//
//  ADBindingDataSource.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/9/18.
//

import Foundation

/// A Data Source conforming to this protocol provides the data to a View Controller conforming to the `ADBindingController` protocol.
public protocol ADBindingDataSource {
    
    /// Causes the data source to reload the data for the attached `ADBindingController` and to redisplay the data in the View the controller manages.
    func reloadData()
    
    /**
     Filters the data displayed in the table based on the given scope and search text:
     
     - Parameters:
     - text: The string to search for.
     - scope: The optional scope to search on.
    */
    func filterData(onSearchText text: String, scope: String)
}
