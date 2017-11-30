//
//  ADSPONEncoder.swift
//  ActionControls
//
//  Created by Kevin Mullins on 10/13/17.
//  Copyright © 2017 Appracatappra, LLC. All rights reserved.
//

import Foundation

/**
 Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SPON database using a `ADSPONiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Encodable`).
 
 ## Example:
 ```
 import ActionUtilities
 import ActionData
 
 class Category: ADDataTable {
 
     enum CategoryType: String, Codable {
         case local
         case web
     }
 
     static var tableName = "Categories"
     static var primaryKey = "id"
     static var primaryKeyType: ADDataTableKeyType = .computedInt
 
     var id = 0
     var added = Date()
     var name = ""
     var description = ""
     var enabled = true
     var highlightColor = UIColor.white.toHex()
     var type: CategoryType = .local
     var icon: Data = UIImage().toData()
 
     required init() {
 
     }
 }
 
 let encoder = ADSPONEncoder()
 let category = Category()
 let data = try encoder.encode(category)
 ```
 
 - Remark: To store `UIColors` in the record use the `toHex()` extension method and to store `UIImages` use the `toData()` extension method.
 */
public class ADSPONEncoder: Encoder {
    
    // MARK: - Enumerations
    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// The raw `Date` instance is encoded in the `ADRecord` and is handled directly by a SQL Data Provider. This is the default strategy.
        case rawDate
        
        /// Defer to `Date` for choosing an encoding.
        case deferredToDate
        
        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970
        
        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970
        
        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)
    }
    
    /// The strategy to use for encoding `Data` values.
    public enum DataEncodingStrategy {
        /// The raw `Data` instance is encoded in the `ADRecord` and is handled directly by a SQL Data Provider. This is the default strategy.
        case rawData
        
        /// Defer to `Data` for choosing an encoding.
        case deferredToData
        
        /// Encoded the `Data` as a Base64-encoded string.
        case base64
    }
    
    // MARK: - Class Functions
    /// Shared formatter used to encode a `Date` as an ISO-8601-formatted string (in RFC 3339 format).
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    public static var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        return formatter
    }()
    
    // MARK: - Properties
    /// The path to the element currently being encoded.
    public var codingPath: [CodingKey] = []
    
    /// User specific, additional information to be encoded in the output.
    public var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Working storage for the object being encoded.
    internal var storage: ADEncodingStorage = ADEncodingStorage()
    
    /// The strategy used to encode `Date` properties. The default is `rawDate` which allow the `ADSPONiteProvider` to handle the date directly.
    public var dateEncodingStrategy: DateEncodingStrategy = .rawDate
    
    /// The strategy used to encode `Data` or `NSData` properties. The default is `rawData` which allow the `ADSPONiteProvider` to handle the data directly.
    public var dataEncodingStrategy: DataEncodingStrategy = .rawData
    
    /// Returns whether a new element can be encoded at this coding path: `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    internal var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }
    
    // MARK: - Initializers
    /**
     Creates a new instance of the encoder.
     
     - Parameters:
     - dateEncodingStrategy: The strategy used to encode `Date` properties. The default is `rawDate` which allow the `ADSPONiteProvider` to handle the date directly.
     - dataEncodingStrategy: The strategy used to encode `Data` or `NSData` properties. The default is `rawData` which allow the `ADSPONiteProvider` to handle the data directly.
     */
    public init(dateEncodingStrategy: DateEncodingStrategy = .rawDate, dataEncodingStrategy: DataEncodingStrategy = .rawData) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
    }
    
    // MARK: - Public Functions
    /**
     Encodes a `Codable` or `Encodable` class into a `ADRecord` that can be written into a SQLite database using a `ADSPONiteProvider`. The result is a dictionary of key/value pairs representing the data currently stored in the class. This encoder will automatically handle `URLs` and `Enums` (if the Enum is value based and also marked `Codable` or `Encodable`). For example:
     
     ```
     enum SwitchState: String, Codable {
         case on
         case off
     }
     ```
     
     ## Example Usage
     
     ```
     let object = MySQLRecordClass()
     let encoder = ADSPONEncoder()
     let record = encoder.encode(object)
     ```
     
     - Remark: To store `UIColors` in the record use the `toHex()` extension method and to store `UIImages` use the `toData()` extension method.
     - Parameter value: The object to encode.
     - Returns: A string representing the data in Swift Portable Object Notation (SPON).
     */
    public func encode<T:Encodable>(_ value: T) throws -> String {
        storage.typeName = String.typeName(of: value)
        try value.encode(to: self)
        let topLevel = storage.popContainer()
        if let record = topLevel as? ADInstanceDictionary {
            return record.encode()
        } else if let array = topLevel as? ADInstanceArray {
            return array.encode()
        } else {
            return "\(topLevel)"
        }
    }
    
    /**
     Returns a key/value encoding container for the given key type.
     
     - Parameter type: The type of key to create an encoding container for.
     - Returns: A `KeyedEncodingContainer` instance for the given key.
     */
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        // If an existing keyed container was already requested, return that one.
        let topContainer: ADInstanceDictionary
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? ADInstanceDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = ADSPONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }
    
    /**
     Returns an unkeyed encodign container.
     
     - Returns: A `UnkeyedEncodingContainer` instance.
     */
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: ADInstanceArray
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? ADInstanceArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        return ADSPONUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }
    
    /**
     Returns a single value encoding container.
     
     - Returns: A `SingleValueEncodingContainer` instance.
     */
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return ADSPONSingleValueEncodingContainer(referencing: self, codingPath: codingPath, into: storage)
    }
    
    // MARK: - Boxing Routines
    internal func box(_ value: Bool) -> Any {
        return value
    }
    
    internal func box(_ value: Int) -> Any {
        return value
    }
    
    internal func box(_ value: Int8) -> Any {
        return value
    }
    
    internal func box(_ value: Int16) -> Any {
        return value
    }
    
    internal func box(_ value: Int32) -> Any {
        return value
    }
    
    internal func box(_ value: Int64) -> Any {
        return value
    }
    
    internal func box(_ value: UInt) -> Any {
        return value
    }
    
    internal func box(_ value: UInt8) -> Any {
        return value
    }
    
    internal func box(_ value: UInt16) -> Any {
        return value
    }
    
    internal func box(_ value: UInt32) -> Any {
        return value
    }
    
    internal func box(_ value: UInt64) -> Any {
        return value
    }
    
    internal func box(_ value: String) -> Any {
        return value
    }
    
    internal func box(_ value: Float) -> Any {
        return value
    }
    
    internal func box(_ value: Double) -> Any {
        return value
    }
    
    public func box(_ date: Date) throws -> Any {
        switch dateEncodingStrategy {
        case .rawDate:
            return date
        case .deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            try date.encode(to: self)
            return self.storage.popContainer()
        case .secondsSince1970:
            return date.timeIntervalSince1970
        case .millisecondsSince1970:
            return 1000.0 * date.timeIntervalSince1970
        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return ADSPONEncoder.iso8601Formatter.string(from: date)
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
        case .formatted(let formatter):
            return formatter.string(from: date)
        }
    }
    
    public func box(_ data: Data) throws -> Any {
        switch dataEncodingStrategy {
        case .rawData:
            return data
        case .deferredToData:
            // Must be called with a surrounding with(pushedKey:) call.
            try data.encode(to: self)
            return self.storage.popContainer()
        case .base64:
            return NSString(string: data.base64EncodedString())
        }
    }
    
    public func box<T : Encodable>(_ value: T) throws -> Any {
        // Throw the instance of the class in the encoding stream if the raw data cannot be encoded.
        return try self.shippingBox(value) ?? value
    }
    
    // This method is called "shippingBox" instead of "box" to disambiguate it from the overloads. Because the return type here is different from all of the "box" overloads (and is more general), any "box" calls in here would call back into "box" recursively instead of calling the appropriate overload, which is not what we want.
    private func shippingBox<T : Encodable>(_ value: T) throws -> Any? {
        if T.self == Date.self || T.self == NSDate.self {
            // Respect Date encoding strategy
            return try self.box((value as! Date))
        } else if T.self == Data.self || T.self == NSData.self {
            // Respect Data encoding strategy
            return try self.box((value as! Data))
        } else if T.self == URL.self || T.self == NSURL.self {
            // Encode URLs as single strings.
            return self.box((value as! URL).absoluteString)
        } else if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            // JSONSerialization can natively handle NSDecimalNumber.
            return (value as! NSDecimalNumber)
        } else if value is ADDataCrossReference {
            // Return the raw cross reference object
            return value
        }
        
        // The value should request a container from the ADSPONEncoder.
        let depth = self.storage.count
        try value.encode(to: self)
        
        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }
        
        // Grab shipping box
        var box = self.storage.popContainer()
        if let dictionary = box as? ADInstanceDictionary {
            // Encode dictionary
            dictionary.typeName = String.typeName(of: value)
            box = dictionary.encode()
        } else if let array = box as? ADInstanceArray {
            // Encode array
            box = array.encode()
        }
        
        // Return newly constructed box
        return box
    }
}
