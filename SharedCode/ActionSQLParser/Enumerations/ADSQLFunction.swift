//
//  ADSQLFunction.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/26/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// Defines the type of functions that can be called in a SQL expression.
public enum ADSQLFunction: String {
    // MARK: - String Functions
    case ltrim = "ltrim"
    case trim = "trim"
    case instr = "instr"
    case replace = "replace"
    case upper = "upper"
    case length = "length"
    case rtrim = "rtrim"
    case lower = "lower"
    case substr = "substr"
    
    // MARK: - Numeric/Math Functions
    case abs = "abs"
    case max = "max"
    case round = "round"
    case avg = "avg"
    case min = "min"
    case sum = "sum"
    case count = "count"
    case random = "random"
    
    // MARK: - Date/Time Functions
    case date = "date"
    case julianday = "julianday"
    case strftime = "strftime"
    case datetime = "datetime"
    case now = "now"
    case time = "time"
    
    // MARK: - Advanced Functions
    case coalesce = "coalesce"
    case lastInsertedRowID = "last_insert_rowid"
    case ifNull = "ifnull"
    case nullIf = "nullif"
    
    // MARK: - Internal Functions
    case check = "@check"
    
    // MARK: - Initializers
    /**
     Attempts to return a function type for the given string value.
     
     - Parameter text: The name of a function.
     - Returns: The function type or `nil` if not found.
    */
    public static func get(fromString text: String) -> ADSQLFunction? {
        let value = text.lowercased()
        return ADSQLFunction(rawValue: value)
    }
}
