//
//  UserConsent.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 19.12.19.
//

import Foundation

/// Indicates the consent status of a given user.
@objc public enum ConsentStatus: Int, Codable {
    /// Indicates the user has rejected none of the vendors or purposes (categories)
    case RejectedNone

    /// Indicates the user has rejected none of the vendors or purposes (categories)
    case RejectedSome

    /// Indicates the user has rejected none of the vendors or purposes (categories)
    case RejectedAll

    /// Indicates the user has **explicitly** acceted all vendors and purposes (categories).
    /// That's slightly different than `RejectNone`. By default in the CCPA users are already
    /// `RejectedNone`, the `ConsentedAll` indicates the user has taken an action to
    /// consent to all vendors and purposes.
    case ConsentedAll

    public typealias RawValue = String

    public var rawValue: RawValue {
        switch self {
        case .ConsentedAll:
            return "consentedAll"
        case .RejectedAll:
            return "rejectedAll"
        case .RejectedSome:
            return "rejectedSome"
        case .RejectedNone:
            return "rejectedNone"
        }
    }

    public init?(rawValue: RawValue) {
        switch rawValue {
        case "consentedAll":
            self = .ConsentedAll
        case "rejectedAll":
            self = .RejectedAll
        case "rejectedSome":
            self = .RejectedSome
        case "rejectedNone":
            self = .RejectedNone
        default:
            return nil
        }
    }
}

/**
    The UserConsent class encapsulates the consent status, rejected vendor ids and rejected categories (purposes) ids.
    - Important: The `rejectedVendors` and `rejectedCategories` arrays will only be populated if the `status` is `.Some`.
    That is, if the user has rejected `.All` or `.None` vendors/categories, those arrays will be empty.
 */
@objcMembers public class UserConsent: NSObject, Codable {
    /// Indicates if the user has rejected `.All`, `.Some` or `.None` of the vendors **and** categories.
    public let status: ConsentStatus
    /// The ids of the rejected vendors and categories. These can be found in SourcePoint's dashboard
    public let rejectedVendors, rejectedCategories: [String]

    public static func rejectedNone () -> UserConsent {
        return UserConsent(status: ConsentStatus.RejectedNone, rejectedVendors: [], rejectedCategories: [])
    }

    public init(status: ConsentStatus, rejectedVendors: [String], rejectedCategories: [String]) {
        self.status = status
        self.rejectedVendors = rejectedVendors
        self.rejectedCategories = rejectedCategories
    }

    open override var description: String { return "Status: \(status.rawValue), rejectedVendors: \(rejectedVendors), rejectedCategories: \(rejectedCategories)" }

    enum CodingKeys: CodingKey {
       case status, rejectedVendors, rejectedCategories
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        rejectedVendors = try values.decode([String].self, forKey: .rejectedVendors)
        rejectedCategories = try values.decode([String].self, forKey: .rejectedCategories)
        let statusString = try values.decode(String.self, forKey: .status)
        switch statusString {
        case "rejectedNone": status = .RejectedNone
        case "rejectedSome": status = .RejectedSome
        case "rejectedAll":  status = .RejectedAll
        case "consentedAll": status = .ConsentedAll
        default: throw MessageEventParsingError(message: "Unknown status string: \(statusString)")
        }
    }
}
