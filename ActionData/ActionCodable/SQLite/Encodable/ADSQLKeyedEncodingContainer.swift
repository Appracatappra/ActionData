//
//  ADSQLKeyedEncodingContainer.swift
//  CoderPlayground
//
//  Created by Kevin Mullins on 9/22/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// A KeyedEncodingContainer used to store key/value pairs while encoding an object. The data will be stored in a `ADInstanceDictionary` during the encoding process.
struct ADSQLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    
    typealias Key = K
    
    var encoder: ADSQLEncoder
    
    var codingPath: [CodingKey]
    
    var container: ADInstanceDictionary
    
    init(referencing encoder: ADSQLEncoder, codingPath: [CodingKey], wrapping container: ADInstanceDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    mutating func encodeNil(forKey key: K) throws {
        container.storage[key.stringValue] = NSNull()
    }
    
    mutating func encode(_ value: Bool, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Int, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Int8, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Int16, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Int32, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Int64, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: UInt, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: UInt8, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: UInt16, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: UInt32, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: UInt64, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Float, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: Double, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode(_ value: String, forKey key: K) throws {
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = encoder.box(value)
    }
    
    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        
        // Assemble key path
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        
        // Encode data into ADSQLRecord
        container.storage[key.stringValue] = try encoder.box(value)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // Build storage and accumulate under key
        let record = ADInstanceDictionary()
        container.storage[key.stringValue] = record
        
        // Assemble key path
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        // Assemble sub container and return
        let subContainer = ADSQLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: record)
        return KeyedEncodingContainer(subContainer)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        // Build storage and accumulate under key
        let array = ADInstanceArray()
        container.storage[key.stringValue] = array
        
        // Assemble key path
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        return ADSQLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    mutating func superEncoder() -> Encoder {
        return ADSQLReferencingEncoder(referencing: encoder, at: ADKey.superKey, wrapping: container)
    }
    
    mutating func superEncoder(forKey key: K) -> Encoder {
        return ADSQLReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }
    
}
