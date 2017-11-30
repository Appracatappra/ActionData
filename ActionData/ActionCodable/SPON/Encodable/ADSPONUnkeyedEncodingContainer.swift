//
//  ADSPONUnkeyedEncodingContainer.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/13/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// A UnkeyedEncodingContainer used to store arrays while encoding an object. The data will be stored in a `ADInstanceArray` during the encoding process.
struct ADSPONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    var encoder: ADSPONEncoder
    
    var codingPath: [CodingKey]
    
    var container: ADInstanceArray
    
    var count: Int {
        return container.storage.count
    }
    
    init(referencing encoder: ADSPONEncoder, codingPath: [CodingKey], wrapping container: ADInstanceArray) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    mutating func encodeNil() throws {
        // Encode a null into the database
        container.storage.append(NSNull())
    }
    
    mutating func encode(_ value: Bool) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Int) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Int8) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Int16) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Int32) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Int64) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: UInt) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: UInt8) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: UInt16) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: UInt32) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: UInt64) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Float) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: Double) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode(_ value: String) throws {
        // Encode data into ADSPONRecord
        container.storage.append(encoder.box(value))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        
        // Assemble key path
        codingPath.append(ADKey(intValue: count)!)
        defer { codingPath.removeLast() }
        
        // FIXME: Store array values
        // Creating a link to a subtable?
        if value is ADDataTable && container.subTableName.isEmpty {
            // Store a reference to the type so a sub table for foreign keys can be
            // created.
            let basetype = T.self as! ADDataTable.Type
            container.subTableName = basetype.tableName
            container.subTablePrimaryKey = basetype.primaryKey
            container.subTablePrimaryKeyType = basetype.primaryKeyType
        }
        
        // Encode data into ADSPONRecord
        let subValue = try encoder.box(value)
        container.storage.append(subValue)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // Assemble key path
        codingPath.append(ADKey(intValue: count)!)
        defer { codingPath.removeLast() }
        
        // Build storage and accumulate
        let record = ADInstanceDictionary()
        container.storage.append(record)
        
        // Assemble sub container and return
        let subContainer = ADSPONKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: record)
        return KeyedEncodingContainer(subContainer)
        
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        // Assemble key path
        codingPath.append(ADKey(intValue: count)!)
        defer { codingPath.removeLast() }
        
        // Build storage and accumulate
        let array = ADInstanceArray()
        container.storage.append(array)
        
        // Assemble sub container and return
        return ADSPONUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    mutating func superEncoder() -> Encoder {
        return ADSPONReferencingEncoder(referencing: encoder, at: container.storage.count, wrapping: container)
    }
    
    
}
