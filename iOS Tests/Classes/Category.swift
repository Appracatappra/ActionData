//
//  Category.swift
//  iOS Tests
//
//  Created by Kevin Mullins on 1/26/18.
//

import Foundation
import ActionUtilities
import ActionData

class Category: ADDataTable {
    
    static var tableName = "Categories"
    static var primaryKey = "id"
    static var primaryKeyType: ADDataTableKeyType = .autoIncrementingInt
    
    var id = -1
    var name = ""
    var description = ""
    var highlightColor = UIColor.red.toHex()
    var use = CategoryUsage.local
    var enabled = true
    
    required init() {
        
    }
    
    init(name: String, description: String, highlight: UIColor = UIColor.white, usage: CategoryUsage = .local, enabled: Bool = true) {
        self.name = name
        self.description = description
        self.highlightColor = highlight.toHex()
        self.use = usage
        self.enabled = enabled
    }
}
