//
//  Appearance.swift
//  iOS Tests
//
//  Created by Kevin Mullins on 1/26/18.
//

import Foundation
import ActionUtilities
import ActionData

class Appearance: ADDataTable {
    
    static var tableName = "Appearances"
    static var primaryKey = "id"
    static var primaryKeyType = ADDataTableKeyType.computedInt
    
    var id = ADSQLiteProvider.shared.makeID(Appearance.self) as! Int
    var hasBorder = true
    var borderWidth = 1
    var borderColor = UIColor.gray.toHex()
    var backgroundColor = UIColor.lightGray.toHex()
    var location = Region()
    var keys = [1,2,3,4]
    
    required init() {
        
    }
}
