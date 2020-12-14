//
//  SPCCPAArbitraryJson.swift
//  CCPAConsentViewController
//
//  Created by Vilas on 13/12/20.
//

import Foundation

public enum SPCCPAArbitraryJson: Codable, CustomStringConvertible, Equatable {
    public var description: String {
        switch self {
        case .string(let string): return "\"\(string)\""
        case .number(let double):
            if let int = Int(exactly: double) {
                return "\(int)"
            } else {
                return "\(double)"
            }
        case .object(let object):
            let keyValues = object
                .map { (key, value) in "\"\(key)\": \(value)" }
                .joined(separator: ",")
            return "{\(keyValues)}"
        case .array(let array):
            return "\(array)"
        case .bool(let bool):
            return "\(bool)"
        case .null:
            return "null"
        }
    }

    public struct Key: CodingKey, Hashable, CustomStringConvertible {
        public var description: String {
            return stringValue
        }
        public let stringValue: String
        public init(_ string: String) { self.stringValue = string }
        public init?(stringValue: String) { self.init(stringValue) }
        public var intValue: Int? { return nil }
        public init?(intValue: Int) { return nil }
    }

    case string(String)
    case number(Double)
    case object([Key: SPCCPAArbitraryJson])
    case array([SPCCPAArbitraryJson])
    case bool(Bool)
    case null

    /// Creates the equivalent of an empty object JSON
    public init() {
        self = .object([:])
    }

    public init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
        } else if let number = try? decoder.singleValueContainer().decode(Double.self) { self = .number(number) } else if let object = try? decoder.container(keyedBy: Key.self) {
            var result: [Key: SPCCPAArbitraryJson] = [:]
            for key in object.allKeys {
                result[key] = (try? object.decode(SPCCPAArbitraryJson.self, forKey: key)) ?? .null
            }
            self = .object(result)
        } else if var array = try? decoder.unkeyedContainer() {
            var result: [SPCCPAArbitraryJson] = []
            for _ in 0..<(array.count ?? 0) {
                result.append(try array.decode(SPCCPAArbitraryJson.self))
            }
            self = .array(result)
        } else if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            self = .bool(bool)
        } else if let isNull = try? decoder.singleValueContainer().decodeNil(), isNull { self = .null
        } else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [],
                                                                         debugDescription: "Unknown SPGDPRArbitraryJson type")) }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .number(let number):
            var container = encoder.singleValueContainer()
            try container.encode(number)
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .object(let object):
            var container = encoder.container(keyedBy: Key.self)
            for (key, value) in object {
                try container.encode(value, forKey: key)
            }
        case .array(let array):
            var container = encoder.unkeyedContainer()
            for value in array {
                try container.encode(value)
            }
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

    public var objectValue: [String: SPCCPAArbitraryJson]? {
        switch self {
        case .object(let object):
            let mapped: [String: SPCCPAArbitraryJson] = Dictionary(uniqueKeysWithValues:
                object.map { (key, value) in (key.stringValue, value) })
            return mapped
        default: return nil
        }
    }

    public var arrayValue: [SPCCPAArbitraryJson]? {
        switch self {
        case .array(let array): return array
        default: return nil
        }
    }

    public subscript(key: String) -> SPCCPAArbitraryJson? {
        guard let jsonKey = Key(stringValue: key),
            case .object(let object) = self,
            let value = object[jsonKey]
            else { return nil }
        return value
    }

    public var stringValue: String? {
        switch self {
        case .string(let string): return string
        default: return nil
        }
    }

    public var nullValue: Any? {
        return nil
    }

    public var doubleValue: Double? {
        switch self {
        case .number(let number): return number
        default: return nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .number(let number): return Int(number)
        default: return nil
        }
    }

    public subscript(index: Int) -> SPCCPAArbitraryJson? {
        switch self {
        case .array(let array): return array[index]
        default: return nil
        }
    }

    public var boolValue: Bool? {
        switch self {
        case .bool(let bool): return bool
        default: return nil
        }
    }

    public var anyValue: Any? {
        switch self {
        case .string(let string): return string
        case .number(let number):
            if let int = Int(exactly: number) { return int } else { return number }
        case .bool(let bool): return bool
        case .object(let object):
            return Dictionary(uniqueKeysWithValues:
                object.compactMap { (key, value) -> (String, Any)? in
                    if let nonNilValue = value.anyValue {
                        return (key.stringValue, nonNilValue)
                    } else { return nil }
                })
        case .array(let array):
            return array.compactMap { $0.anyValue }
        case .null:
            return nil
        }
    }

    public var dictionaryValue: [String: Any]? {
        return anyValue as? [String: Any]
    }

    public subscript(dynamicMember member: String) -> SPCCPAArbitraryJson {
        return self[member] ?? .null
    }
}

public extension SPCCPAArbitraryJson {
    init(_ value: Any) throws {
        if let string = value as? String { self = .string(string) } else if let number = value as? NSNumber {
            switch CFGetTypeID(number as CFTypeRef) {
            case CFBooleanGetTypeID():
                self = .bool(number.boolValue)
            case CFNumberGetTypeID():
                self = .number(number.doubleValue)
            default:
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Cannot encode value"))
            }
        } else if let object = value as? [String: Any] {
            var result: [Key: SPCCPAArbitraryJson] = [:]
            for (key, subvalue) in object {
                result[Key(key)] = try SPCCPAArbitraryJson(subvalue)
            }
            self = .object(result)
        } else if let array = value as? [Any] {
            self = .array(try array.map(SPCCPAArbitraryJson.init))
        } else if case Optional<Any>.none = value {
            self = .null
        } else if let obj = value as? NSObject, obj.isEqual(NSNull()) {
            self = .null
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Cannot encode value"))
        }
    }
}
