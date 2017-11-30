//
//  ADSQLColumnType.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/19/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// Defines the type of a column stored in a SQL data source.
public enum ADSQLColumnType: String {
    case nullType = "NULL"
    case integerType = "INTEGER"
    case floatType = "FLOAT"
    case textType = "TEXT"
    case blobType = "BLOB"
    case noneType = "NONE"
    case dateType = "DATE"
    case boolType = "BOOLEAN"
    
    /**
     Attempts to get the type from a string.
     
     - Parameter text: The name of a column type.
     - Returns: The column type or `nil` if not found.
    */
    public static func get(fromString text: String) -> ADSQLColumnType? {
        let value = text.lowercased()
        
        // Take action based on the value
        switch value {
        case "null":
            return .nullType
        case "int", "integer":
            return .integerType
        case "real", "float", "double":
            return .floatType
        case "char", "clob", "text":
            return.textType
        case "blob":
            return .blobType
        case "none":
            return .noneType
        case "date":
            return .dateType
        case "bool", "boolean":
            return .boolType
        default:
            // Not a known type
            return nil
        }
    }
    
    /**
     Sets the column type from a string value.
     
     - Parameter text: The name of the column type.
     - Remark: The type will default to `nullType` if the given type is not found.
    */
    public mutating func set(fromString text: String) {
        let value = text.lowercased()
        
        // Take action based on the value
        switch value {
        case "null":
            self = .nullType
        case "int", "integer":
            self = .integerType
        case "real", "float", "double":
            self = .floatType
        case "char", "clob", "text":
            self = .textType
        case "blob":
            self = .blobType
        case "date":
            self = .dateType
        case "bool", "boolean":
            self = .boolType
        default:
            // Default to no type
            self = .noneType
        }
    }
}
