//
//  SourcePointClient.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 13.03.19.
//

import Foundation

typealias OnSuccess = (Data) -> Void
typealias OnError = (CCPAConsentViewControllerError?) -> Void

protocol HttpClient {
    var defaultOnError: OnError? { get set }
    
    func get(url: URL?, onSuccess: @escaping OnSuccess)
    func post(url: URL?, body: Data?, onSuccess: @escaping OnSuccess)
}

class SimpleClient: HttpClient {
    var defaultOnError: OnError?
    let connectivityManager: Connectivity
    
    init(connectivityManager: Connectivity) {
        self.connectivityManager = connectivityManager
    }
    
    convenience init() {
        self.init(connectivityManager: ConnectivityManager.shared)
    }
    
    func request(_ urlRequest: URLRequest, _ onSuccess: @escaping OnSuccess) {
        if(connectivityManager.isConnectedToNetwork()) {
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async { [weak self] in
                    guard let data = data else {
                        self?.defaultOnError?(GeneralRequestError(urlRequest.url, response, error))
                        return
                    }
                    onSuccess(data)
                }
            }.resume()
        } else {
            defaultOnError?(NoInternetConnection())
        }
    }
    
    func post(url: URL?, body: Data?, onSuccess: @escaping OnSuccess) {
        guard let _url = url else {
            defaultOnError?(GeneralRequestError(url, nil, nil))
            return
        }
        var urlRequest = URLRequest(url: _url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        request(urlRequest, onSuccess)
    }
    
    func get(url: URL?, onSuccess: @escaping OnSuccess) {
        guard let _url = url else {
            defaultOnError?(GeneralRequestError(url, nil, nil))
            return
        }
        request(URLRequest(url: _url), onSuccess)
    }
}

typealias TargetingParams = [String:Codable]

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
    
    private let accountId: Int
    private let propertyId: Int
    private let propertyName: PropertyName
    private let pmId: String
    private let campaignEnv: CampaignEnv
    
    public var onError: OnError? { didSet { client.defaultOnError = onError } }

    init(accountId: Int, propertyId:Int, propertyName: PropertyName, pmId:String, campaignEnv: CampaignEnv, client: HttpClient) {
        self.accountId = accountId
        self.propertyId = propertyId
        self.propertyName = propertyName
        self.pmId = pmId
        self.campaignEnv = campaignEnv
        self.client = client
    }
    
    convenience init(accountId: Int, propertyId: Int, propertyName: PropertyName, pmId: String, campaignEnv: CampaignEnv) {
        self.init(accountId: accountId, propertyId: propertyId, propertyName: propertyName, pmId: pmId, campaignEnv: campaignEnv, client: SimpleClient())
    }

    func getMessageUrl(_ consentUUID: ConsentUUID?, propertyName: PropertyName) -> URL? {
        var components = URLComponents(url: SourcePointClient.WRAPPER_API, resolvingAgainstBaseURL: true)
        components?.path = "/ccpa/message-url"
        components?.queryItems = [
            URLQueryItem(name: "uuid", value: consentUUID),
            URLQueryItem(name: "propertyId", value: String(propertyId)),
            URLQueryItem(name: "accountId", value: String(accountId)),
            URLQueryItem(name: "requestUUID", value: requestUUID.uuidString),
            URLQueryItem(name: "propertyHref", value: propertyName.rawValue),
            URLQueryItem(name: "campaignEnv", value: campaignEnv == .Stage ? "stage" : "prod"),
            URLQueryItem(name: "meta", value: UserDefaults.standard.string(forKey: CCPAConsentViewController.META_KEY)),
        ]
        return components?.url
    }

    func getMessage(consentUUID: ConsentUUID?, onSuccess: @escaping (MessageResponse) -> Void) {
        let url = getMessageUrl(consentUUID, propertyName: propertyName)
        client.get(url: url) { [weak self] data in
            do {
                let messageResponse = try (self?.json.decode(MessageResponse.self, from: data))!
                UserDefaults.standard.setValue(messageResponse.meta, forKey: CCPAConsentViewController.META_KEY)
                onSuccess(messageResponse)
            } catch {
                self?.onError?(APIParsingError(url?.absoluteString ?? "getMessage", error))
            }
        }
    }
    
    func postActionUrl(_ actionType: Int) -> URL? {
        return URL(
            string: "ccpa/consent/\(actionType)",
            relativeTo: SourcePointClient.WRAPPER_API
        )
    }
    
    func postAction(action: Action, consentUUID: ConsentUUID?, consents: PMConsents?, onSuccess: @escaping (ActionResponse) -> Void) {
        let url = postActionUrl(action.rawValue)
        let meta = UserDefaults.standard.string(forKey: CCPAConsentViewController.META_KEY) ?? "{}"
        let ccpaConsents = CPPAPMConsents(rejectedVendors: consents?.vendors.rejected ?? [], rejectedCategories: consents?.categories.rejected ?? [])
        guard let body = try? json.encode(ActionRequest(propertyId: propertyId, accountId: accountId, privacyManagerId: pmId, uuid: consentUUID, requestUUID: requestUUID, consents: ccpaConsents, meta: meta)) else {
            self.onError?(APIParsingError(url?.absoluteString ?? "POST consent", nil))
            return
        }
        
        client.post(url: url, body: body) { [weak self] data in
            do {
                let actionResponse = try (self?.json.decode(ActionResponse.self, from: data))!
                UserDefaults.standard.setValue(actionResponse.meta, forKey: CCPAConsentViewController.META_KEY)
                onSuccess(actionResponse)
            } catch {
                self?.onError?(APIParsingError(url?.absoluteString ?? "POST consent", error))
            }
        }
    }
}
