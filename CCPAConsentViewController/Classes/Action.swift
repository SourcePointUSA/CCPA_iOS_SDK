//
//  Action.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 11.12.19.
//

import Foundation

/// User actions. Its integer representation matches with what SourcePoint's endpoints expect.
@objc public enum ActionType: Int, Codable, CaseIterable, CustomStringConvertible {
    case SaveAndExit = 1
    case AcceptAll = 11
    case ShowPrivacyManager = 12
    case RejectAll = 13
    case Dismiss = 15
    public var description: String {
        switch self {
        case .AcceptAll: return "AcceptAll"
        case .RejectAll: return "RejectAll"
        case .ShowPrivacyManager: return "ShowPrivacyManager"
        case .SaveAndExit: return "SaveAndExit"
        case .Dismiss: return "Dismiss"
        default: return "Unknown"
        }
    }
}

/// Action consists of `ActionType` and publisherData.
@objcMembers public class Action: NSObject {
    public let type: ActionType
    public var publisherData: [String: SPCCPAArbitraryJson?] = [:]

    public override var description: String {
        """
        GDPRAction(type: \(type), publisherData: \(String(describing: publisherData))
        """
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Action else {
            return false
        }
        return other.type == type &&
            other.publisherData == publisherData
    }

    public init(type: ActionType) {
        self.type = type
    }
}
