//
//  ADBoundSQLTableViewDetailController.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/23/18.
//

import Foundation

open class ADBoundSQLTableViewDetailController: ADBoundViewController, ADBindingDetailController {
    public var dataSource: ADBindingDataSource?
    
    public var indexPath: IndexPath?
    
    public var forceReload: Bool
    
    
}
