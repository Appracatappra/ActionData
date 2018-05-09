//
//  ADBoundTableSection.swift
//  ActionData iOS
//
//  Created by Kevin Mullins on 5/3/18.
//

import Foundation

/**
 Holds information about a section automatically created by a `ADBoundTableViewDataSource` when the parent `ADBoundTableView` has been set to group data (`groupData` = `true`) and a valid `groupPath` has been specified. The `ADBoundTableSection` contains an index that points to the raw data in the `ADBoundTableViewDataSource` and optianally provides a section title and footer.
 */
open class ADBoundTableSection {
    
    /// Defines the title for the section. If empty string (`""`), no title is presented.
    public var title: String = ""
    
    /// Contains a reference pointer to the raw data for this item in the group.
    public var index: [Int] = []
    
    /// Defines the footer for the section. If empty string (`""`), no footer is presented.
    public var footer: String = ""
    
}
