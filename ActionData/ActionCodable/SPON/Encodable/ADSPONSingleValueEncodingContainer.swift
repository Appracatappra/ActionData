//
//  ADSPONSingleValueEncodingContainer.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/13/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// A SingleValueEncodingContainer used to store individual values while encoding an object. The data will be stored directly in the `ADEncodingStorage` during the encoding process.
struct ADSPONSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    var encoder: ADSPONEncoder
    
    var codingPath: [CodingKey]
    
    var storage: ADEncodingStorage
    
    init(referencing encoder: ADSPONEncoder, codingPath: [CodingKey], into storage: ADEncodingStorage) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.storage = storage
    }
    
    mutating func encodeNil() throws {
        storage.push(container: NSNull())
    }
    
    mutating func encode(_ value: Bool) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Int) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Int8) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Int16) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Int32) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Int64) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: UInt) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: UInt8) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: UInt16) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: UInt32) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: UInt64) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Float) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: Double) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode(_ value: String) throws {
        // Add to storage
        storage.push(container: encoder.box(value))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        // Add to storage
        let subValue = try encoder.box(value)
        storage.push(container: subValue)
    }
}
