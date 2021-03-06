//
//  SourcePointClient.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 13.03.19.
//

import Foundation

struct JSON {
    private lazy var jsonDecoder: JSONDecoder = { return JSONDecoder() }()
    private lazy var jsonEncoder: JSONEncoder = { return JSONEncoder() }()

    mutating func decode<T: Decodable>(_ decodable: T.Type, from data: Data) throws -> T {
        return try jsonDecoder.decode(decodable, from: data)
    }

    mutating func encode<T: Encodable>(_ encodable: T) throws -> Data {
        return try jsonEncoder.encode(encodable)
    }
}

/**
A Http client for SourcePoint's endpoints
 - Important: it should only be used the SDK as its public API is still in constant development and is probably going to change.
 */
class SourcePointClient {
    static let WRAPPER_API = URL(string: "https://wrapper-api.sp-prod.net")!
    static let CMP_URL = URL(string: "https://sourcepoint.mgr.consensu.org")!

    private var client: HttpClient
    private lazy var json: JSON = { return JSON() }()

    let requestUUID = UUID()
    let accountId: Int
    let propertyId: Int
    let propertyName: PropertyName
    let pmId: String
    let campaignEnv: CampaignEnv
    let targetingParams: TargetingParams

    init(accountId: Int, propertyId: Int, propertyName: PropertyName, pmId: String, campaignEnv: CampaignEnv, targetingParams: TargetingParams, client: HttpClient) {
        self.accountId = accountId
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.pmId = pmId
        self.campaignEnv = campaignEnv
        self.client = client
        self.targetingParams = targetingParams
    }

    convenience init(accountId: Int, propertyId: Int, propertyName: PropertyName, pmId: String, campaignEnv: CampaignEnv, targetingParams: TargetingParams) {
        self.init(accountId: accountId,
                  propertyId: propertyId,
                  propertyName: propertyName,
                  pmId: pmId,
                  campaignEnv: campaignEnv,
                  targetingParams: targetingParams,
                  client: SimpleClient())
    }

    func targetingParamsToString(_ params: TargetingParams) -> String {
        let emptyParams = "{}"
        do {
            let data = try JSONSerialization.data(withJSONObject: params)
            return String(data: data, encoding: .utf8) ?? emptyParams
        } catch {
            return emptyParams
        }
    }

    func getMessageUrl(_ consentUUID: ConsentUUID, propertyName: PropertyName, authId: String?) -> URL? {
        var components = URLComponents(url: SourcePointClient.WRAPPER_API, resolvingAgainstBaseURL: true)
        components?.path = "/ccpa/message-url"
        components?.queryItems = [
            URLQueryItem(name: "uuid", value: consentUUID),
            URLQueryItem(name: "authId", value: authId),
            URLQueryItem(name: "propertyId", value: String(propertyId)),
            URLQueryItem(name: "accountId", value: String(accountId)),
            URLQueryItem(name: "requestUUID", value: requestUUID.uuidString),
            URLQueryItem(name: "propertyHref", value: propertyName.rawValue),
            URLQueryItem(name: "campaignEnv", value: campaignEnv == .Stage ? "stage" : "prod"),
            URLQueryItem(name: "targetingParams", value: targetingParamsToString(targetingParams)),
            URLQueryItem(name: "alwaysDisplayDNS", value: String(false)),
            URLQueryItem(name: "meta", value: UserDefaults.standard.string(forKey: CCPAConsentViewController.META_KEY))
        ]
        return components?.url
    }

    func getMessage(consentUUID: ConsentUUID, authId: String?, completionHandler: @escaping (MessageResponse?, CCPAAPIParsingError?) -> Void) {
        let url = getMessageUrl(consentUUID, propertyName: propertyName, authId: authId)
        client.get(url: url) { [weak self] data, error in
            do {
                if let messageData = data {
                    let messageResponse = try (self?.json.decode(MessageResponse.self, from: messageData))
                    UserDefaults.standard.setValue(messageResponse?.meta, forKey: CCPAConsentViewController.META_KEY)
                    completionHandler(messageResponse, nil)
                } else {
                    completionHandler(nil, CCPAAPIParsingError(url?.absoluteString ?? "getMessage", error))
                }
            } catch {
                completionHandler(nil, CCPAAPIParsingError(url?.absoluteString ?? "getMessage", error))
            }
        }
    }

    func postActionUrl(_ actionType: Int) -> URL? {
        return URL(
            string: "ccpa/consent/\(actionType)",
            relativeTo: SourcePointClient.WRAPPER_API
        )
    }

    func postAction(action: Action, consentUUID: ConsentUUID, consents: PMConsents?, completionHandler: @escaping (ActionResponse?, CCPAAPIParsingError?) -> Void) {
        let url = postActionUrl(action.type.rawValue)
        let meta = UserDefaults.standard.string(forKey: CCPAConsentViewController.META_KEY) ?? "{}"
        let ccpaConsents = CCPAPMConsents(rejectedVendors: consents?.vendors.rejected ?? [], rejectedCategories: consents?.categories.rejected ?? [])
        guard let body = try? json.encode(ActionRequest(
            propertyId: propertyId,
            accountId: accountId,
            privacyManagerId: pmId,
            uuid: consentUUID,
            requestUUID: requestUUID,
            consents: ccpaConsents,
            meta: meta,
            publisherData: action.publisherData
        )) else {
            completionHandler(nil, CCPAAPIParsingError(url?.absoluteString ?? "POST consent", nil))
            return
        }

        client.post(url: url, body: body) { [weak self] data, error in
            do {
                if let actionData = data {
                    let actionResponse = try (self?.json.decode(ActionResponse.self, from: actionData))
                    UserDefaults.standard.setValue(actionResponse?.meta, forKey: CCPAConsentViewController.META_KEY)
                    completionHandler(actionResponse, nil)
                } else {
                    completionHandler(nil, CCPAAPIParsingError(url?.absoluteString ?? "POST consent", error))
                }
            } catch {
                completionHandler(nil, CCPAAPIParsingError(url?.absoluteString ?? "POST consent", error))
            }
        }
    }
}
