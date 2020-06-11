//
//  SourcePointRequestsResponses.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 15.12.19.
//

import Foundation

public typealias CCPAString = String
public typealias Meta = String
public typealias ConsentUUID = String

protocol WrapperApiRequest: Codable, Equatable {
    var requestUUID: UUID { get }
    var meta: Meta { get }
}

struct MessageResponse: Codable, Equatable {
    let url: URL?
    let uuid: ConsentUUID
    let userConsent: UserConsent
    var meta: Meta
}

struct ActionResponse: Codable, Equatable {
    let uuid: ConsentUUID
    let userConsent: UserConsent
    var meta: Meta
}

struct ActionRequest: WrapperApiRequest {
    static func == (lhs: ActionRequest, rhs: ActionRequest) -> Bool {
        lhs.requestUUID == rhs.requestUUID
    }

    let propertyId, accountId: Int
    let privacyManagerId: String
    let uuid: ConsentUUID
    let requestUUID: UUID
    let consents: CPPAPMConsents
    let meta: Meta
}

@objc public class PMConsents: NSObject, Codable {
    let vendors, categories: PMConsent
    
    public init(vendors: PMConsent, categories: PMConsent) {
        self.vendors = vendors
        self.categories = categories
    }
}

@objc public class PMConsent: NSObject, Codable {
    let accepted, rejected: [String]
    
    public init(accepted: [String], rejected: [String]) {
        self.accepted = accepted
        self.rejected = rejected
    }
}

struct CPPAPMConsents: Codable {
    let rejectedVendors, rejectedCategories: [String]
}
