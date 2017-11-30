//
//  ADSPONReferencingEncoder.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/13/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/// A ReferencingEncoder used to store sub class values while encoding an object. The data will be stored directly in the `ADEncodingStorage` during the encoding process.
class ADSPONReferencingEncoder: ADSPONEncoder {
    
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(ADInstanceArray, Int)
        
        /// Referencing a specific key in a dictionary container.
        case dictionary(ADInstanceDictionary, String)
    }
    
    var encoder: ADSPONEncoder
    
    private var reference: Reference
    
    init(referencing encoder: ADSPONEncoder, at index: Int, wrapping array: ADInstanceArray) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init()
        
        // FIXME: Keypath
        // Disabled key path here seems to fix issue with encoding sub containers.
        //self.codingPath.append(ADKey(intValue: index)!)
    }
    
    init(referencing encoder: ADSPONEncoder, at key: CodingKey, wrapping dictionary: ADInstanceDictionary) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init()
        
        // FIXME: Keypath
        // Disabled key path here seems to fix issue with encoding sub containers.
        //self.codingPath.append(key) // TODO - Might need more params here
    }
    
    deinit {
        let value: Any
        switch self.storage.count {
        case 0:
            value = ADRecord()
        case 1:
            value = self.storage.popContainer()
        default:
            fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        switch self.reference {
        case .array(let array, let index):
            array.storage.insert(value, at: index)
            
        case .dictionary(let dictionary, let key):
            dictionary.storage[key] = value
        }
    }
}
