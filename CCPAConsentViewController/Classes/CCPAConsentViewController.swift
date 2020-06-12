//
//  CCPAConsentViewController.swift
//  cmp-app-test-app
//
//  Created by Andre Herculano on 12/16/19.
//  Copyright © 2019 Sourcepoint. All rights reserved.
//

import UIKit

public typealias TargetingParams = [String: String]

@objcMembers open class CCPAConsentViewController: UIViewController {
    static public let CCPA_USER_CONSENTS: String = "sp_ccpa_user_consents"
    static public let CONSENT_UUID_KEY: String = "sp_ccpa_consentUUID"
    static let CCPA_AUTH_ID_KEY = "sp_ccpa_authId"
    static public let META_KEY: String = "sp_ccpa_meta"
    public static let IAB_PRIVACY_STRING_KEY = "IABUSPrivacy_String"
    public static let CCPA_APPLIES_KEY = "sp_ccpa_applies"

    static func setUSPrivacyString(_ usps: SPUsPrivacyString) {
        UserDefaults.standard.set(usps, forKey: IAB_PRIVACY_STRING_KEY)
    }

    static func setCCPAApplies(_ applies: Bool) {
        UserDefaults.standard.set(applies, forKey: CCPA_APPLIES_KEY)
    }

    private let accountId, propertyId: Int
    private let propertyName: PropertyName
    private let pmId: String

    private let targetingParams: TargetingParams

    private let sourcePoint: SourcePointClient

    public weak var consentDelegate: ConsentDelegate?
    var messageViewController: MessageViewController?

    enum LoadingStatus: String {
        case Ready
        case Presenting
        case Loading
    }

    // used in order not to load the message ui multiple times
    var loading: LoadingStatus = .Ready

    func remove(asChildViewController viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    static func getStoredUserConsents() -> UserConsent {
        guard
            let jsonConsents = UserDefaults.standard.string(forKey: CCPA_USER_CONSENTS),
            let jsonData = jsonConsents.data(using: .utf8),
            let userConsent = try? JSONDecoder().decode(UserConsent.self, from: jsonData)
        else {
            return UserConsent.rejectedNone()
        }
        return userConsent
    }

    static func getStoredConsentUUID() -> ConsentUUID {
        return UserDefaults.standard.string(forKey: CONSENT_UUID_KEY) ?? ""
    }

    /// Contains the `ConsentStatus`, an array of rejected vendor ids and and array of rejected purposes
    public var userConsent: UserConsent

    /// The UUID assigned to a user, available after calling `loadMessage`
    public var consentUUID: ConsentUUID

    /// Instructs the SDK to clean consent data if an error occurs. It's `true` by default.
    public var shouldCleanConsentOnError = true

    /**
       - Parameters:
           - accountId: the id of your account, can be found in the Account section of SourcePoint's dashboard
           - propertyId: the id of your property, can be found in the property page of SourcePoint's dashboard
           - propertyName: the exact name of your property,
           - PMId: the id of the PrivacyManager, can be found in the PrivacyManager page of SourcePoint's dashboard
           - campaignEnv: Indicates if the SDK should load the message from the Public or Stage campaign
           - consentDelegate: responsible for dealing with the different consent lifecycle functions.
       - SeeAlso: ConsentDelegate
    */
    public convenience init(
        accountId: Int,
        propertyId: Int,
        propertyName: PropertyName,
        PMId: String,
        campaignEnv: CampaignEnv,
        consentDelegate: ConsentDelegate
    ) {
        self.init(accountId: accountId,
                  propertyId: propertyId,
                  propertyName: propertyName,
                  PMId: PMId,
                  campaignEnv: campaignEnv,
                  targetingParams: [:],
                  consentDelegate: consentDelegate)
    }

    /**
       - Parameters:
           - accountId: the id of your account, can be found in the Account section of SourcePoint's dashboard
           - propertyId: the id of your property, can be found in the property page of SourcePoint's dashboard
           - propertyName: the exact name of your property,
           - PMId: the id of the PrivacyManager, can be found in the PrivacyManager page of SourcePoint's dashboard
           - campaignEnv: Indicates if the SDK should load the message from the Public or Stage campaign
           - targetingParams: A dictionary of arbitrary key/value pairs of string to be used in the scenario builder
           - consentDelegate: responsible for dealing with the different consent lifecycle functions.
       - SeeAlso: ConsentDelegate
    */
    public init(
        accountId: Int,
        propertyId: Int,
        propertyName: PropertyName,
        PMId: String,
        campaignEnv: CampaignEnv,
        targetingParams: TargetingParams,
        consentDelegate: ConsentDelegate
    ) {
        self.accountId = accountId
        self.propertyName = propertyName
        self.propertyId = propertyId
        self.pmId = PMId
        self.targetingParams = targetingParams
        self.consentDelegate = consentDelegate

        self.userConsent = CCPAConsentViewController.getStoredUserConsents()
        self.consentUUID = CCPAConsentViewController.getStoredConsentUUID()

        self.sourcePoint = SourcePointClient(
            accountId: accountId,
            propertyId: propertyId,
            propertyName: propertyName,
            pmId: PMId,
            campaignEnv: campaignEnv,
            targetingParams: targetingParams
        )

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMessage(fromUrl url: URL) {
        messageViewController = MessageWebViewController(propertyId: propertyId, pmId: pmId, consentUUID: consentUUID)
        messageViewController?.consentDelegate = self
        messageViewController?.loadMessage(fromUrl: url)
    }

    /// Will first check if there's a message to show according to the scenario, for the `authId` provided.
    /// If there is, we'll load the message in a WebView and call `ConsentDelegate.onConsentUIWillShow`
    /// Otherwise, we short circuit to `ConsentDelegate.onConsentReady`
    ///
    /// - Parameter authId: any arbitrary token that uniquely identifies an user in your system.
    public func loadMessage(forAuthId authId: String?) {
        if loading == .Ready {
            loading = .Loading
            UserDefaults.standard.setValue(authId, forKey: CCPAConsentViewController.CCPA_AUTH_ID_KEY)
            if didAuthIdChange(newAuthId: (authId)) {
                resetConsentData()
            }
            sourcePoint.getMessage(consentUUID: consentUUID, authId: authId) { [weak self] messageResponse, error in
                self?.loading = .Ready
                if let message = messageResponse {
                    self?.setLocalStorageData(uuid: message.uuid, userConsent: message.userConsent, ccpaApplies: message.ccpaApplies)
                    self?.consentUUID = message.uuid
                    self?.userConsent = message.userConsent
                    if let url = message.url {
                        self?.loadMessage(fromUrl: url)
                    } else {
                        self?.onConsentReady(consentUUID: message.uuid, userConsent: message.userConsent)
                    }
                } else {
                    self?.onError(error: error)
                }
            }
        }
    }

    func setLocalStorageData(uuid: ConsentUUID, userConsent: UserConsent, ccpaApplies: Bool) {
        UserDefaults.standard.set(uuid, forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        CCPAConsentViewController.setUSPrivacyString(userConsent.uspstring)
        CCPAConsentViewController.setCCPAApplies(ccpaApplies)
        if let encodedConsents = try? JSONEncoder().encode(userConsent) {
            UserDefaults.standard.set(String(data: encodedConsents, encoding: .utf8), forKey: CCPAConsentViewController.CCPA_USER_CONSENTS)
        }
        UserDefaults.standard.synchronize()
    }

    func didAuthIdChange(newAuthId: String?) -> Bool {
        let storedAuthId = UserDefaults.standard.string(forKey: CCPAConsentViewController.CCPA_AUTH_ID_KEY)
        return newAuthId != nil && storedAuthId != nil && storedAuthId != newAuthId
    }

    /// Will first check if there's a message to show according to the scenario setup in our dashboard.
    /// If there is, we'll load the message in a WebView and call `ConsentDelegate.onConsentUIWillShow`
    /// Otherwise, we short circuit to `ConsentDelegate.onConsentReady`
    public func loadMessage() {
        loadMessage(forAuthId: nil)
    }

    public func loadPrivacyManager() {
        if loading == .Ready {
            loading = .Loading
            messageViewController = MessageWebViewController(propertyId: propertyId, pmId: pmId, consentUUID: consentUUID)
            messageViewController?.consentDelegate = self
            messageViewController?.loadPrivacyManager()
        }
    }

    func resetConsentData() {
        self.consentUUID = ""
        clearAllConsentData()
    }

    /// Remove all consent related data from the UserDefaults
    public func clearAllConsentData() {
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.CCPA_AUTH_ID_KEY)
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.CCPA_USER_CONSENTS)
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.META_KEY)
        UserDefaults.standard.synchronize()
    }
}

extension CCPAConsentViewController: ConsentDelegate {
    public func ccpaConsentUIWillShow() {
        guard let viewController = messageViewController else { return }
        add(asChildViewController: viewController)
        consentDelegate?.ccpaConsentUIWillShow?()
        consentDelegate?.consentUIWillShow?()
    }

    public func consentUIDidDisappear() {
        loading = .Ready
        remove(asChildViewController: messageViewController)
        messageViewController = nil
        consentDelegate?.consentUIDidDisappear?()
    }

    public func onError(error: CCPAConsentViewControllerError?) {
        loading = .Ready
        if shouldCleanConsentOnError {
            clearAllConsentData()
        }
        consentDelegate?.onError?(error: error)
    }

    public func onAction(_ action: Action, consents: PMConsents?) {
        if action == .AcceptAll || action == .RejectAll || action == .SaveAndExit {
            sourcePoint.postAction(action: action, consentUUID: consentUUID, consents: consents) { [weak self] actionResponse, error in
                if let response = actionResponse {
                    self?.consentUUID = response.uuid
                    self?.userConsent = response.userConsent
                    self?.setLocalStorageData(uuid: response.uuid, userConsent: response.userConsent, ccpaApplies: response.ccpaApplies)
                    self?.onConsentReady(consentUUID: response.uuid, userConsent: response.userConsent)
                } else {
                    self?.onError(error: error)
                }
            }
        }
    }

    public func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        consentDelegate?.onConsentReady?(consentUUID: consentUUID, userConsent: userConsent)
    }

    public func messageWillShow() { consentDelegate?.messageWillShow?() }
    public func messageDidDisappear() { consentDelegate?.messageDidDisappear?() }
    public func ccpaPMWillShow() { consentDelegate?.ccpaPMWillShow?() }
    public func ccpaPMDidDisappear() { consentDelegate?.ccpaPMDidDisappear?() }
}
