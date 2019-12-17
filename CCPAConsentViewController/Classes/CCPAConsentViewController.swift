//
//  CCPAConsentViewController.swift
//  cmp-app-test-app
//
//  Created by Andre Herculano on 12/16/19.
//  Copyright © 2019 Sourcepoint. All rights reserved.
//

import UIKit

@objcMembers open class CCPAConsentViewController: UIViewController {
    /// :nodoc:
    public enum DebugLevel: String {
        case DEBUG, INFO, TIME, WARN, ERROR, OFF
    }

    /// :nodoc:
    static public let CCPA_CONSENT_KEY: String = "ccpastring"
    /// :nodoc:
    static public let CONSENT_UUID_KEY: String = "consentUUID"

    /// :nodoc:
    public var debugLevel: DebugLevel = .OFF

    public var ccpaString: CCPAString?

    /// The UUID assigned to the user, set after the user has chosen after interacting with the CCPAConsentViewController
    public var consentUUID: UUID?

    /// The timeout interval in seconds for the message being displayed
    public var messageTimeoutInSeconds = TimeInterval(300)

    private let accountId: Int
    private let property: String
    private let propertyId: Int
    private let pmId: String

    typealias TargetingParams = [String:String]
    private let targetingParams: TargetingParams = [:]

    private let sourcePoint: SourcePointClient
    private lazy var logger = { return Logger() }()

    /// will instruct the SDK to clean consent data if an error occurs
    public var shouldCleanConsentOnError = true

    private weak var consentDelegate: ConsentDelegate?
    private var messageViewController: MessageViewController?
    
    enum LoadingStatus: String {
        case Ready = "Ready"
        case Presenting = "Presenting"
        case Loading = "Loading"
    }
    /// used in order not to load the message ui multiple times
    private var loading: LoadingStatus = .Ready

    private func remove(asChildViewController viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    /**
     Initialises the library with `accountId`, `propertyId`, `property`, `PMId`,`campaign` and `messageDelegate`.
     */
    public init(
        accountId: Int,
        propertyId: Int,
        property: String,
        PMId: String,
        campaign: String,
        consentDelegate: ConsentDelegate
    ){
        self.accountId = accountId
        self.property = property
        self.propertyId = propertyId
        self.pmId = PMId
        self.consentDelegate = consentDelegate

        self.sourcePoint = SourcePointClient(
            accountId: accountId,
            propertyId: propertyId,
            pmId: PMId,
            campaign: campaign,
            onError: consentDelegate.onError(error:)
        )

        self.ccpaString = UserDefaults.standard.string(forKey: CCPAConsentViewController.CCPA_CONSENT_KEY)
        self.consentUUID = UUID(uuidString: UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY) ?? "")

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getConsents(forUUID uuid: UUID, consentString: CCPAString?) {
        sourcePoint.getCustomConsents(consentUUID: uuid) { [weak self] consents in
            self?.onConsentReady(
                consentUUID: uuid,
                consents: consents.consentedPurposes + consents.consentedVendors,
                consentString: consentString
            )
        }
    }
    
    private func loadMessage(fromUrl url: URL) {
        messageViewController = MessageWebViewController(propertyId: propertyId, pmId: pmId, consentUUID: consentUUID)
        messageViewController?.consentDelegate = self
        messageViewController?.loadMessage(fromUrl: url)
    }
    
    public func loadMessage() {
        if loading == .Ready {
            loading = .Loading
            sourcePoint.getMessage(accountId: accountId, propertyId: propertyId) { [weak self] message in
                if let url = message.url {
                    self?.loadMessage(fromUrl: url)
                } else {
                    self?.getConsents(forUUID: message.uuid, consentString: message.ccpaString)
                }
            }
        }
    }

    public func loadPrivacyManager() {
        if loading == .Ready {
            loading = .Loading
            messageViewController = MessageWebViewController(propertyId: propertyId, pmId: pmId, consentUUID: consentUUID)
            messageViewController?.consentDelegate = self
            messageViewController?.loadPrivacyManager()
        }
    }

    /// It will clear all the stored userDefaults Data
    public func clearAllConsentData() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: CCPAConsentViewController.CCPA_CONSENT_KEY)
        userDefaults.removeObject(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        userDefaults.synchronize()
    }
}

extension CCPAConsentViewController: ConsentDelegate {
    public func consentUIWillShow() {
        guard let viewController = messageViewController else { return }
        add(asChildViewController: viewController)
        consentDelegate?.consentUIWillShow()
    }

    public func consentUIDidDisappear() {
        loading = .Ready
        remove(asChildViewController: messageViewController)
        messageViewController = nil
        consentDelegate?.consentUIDidDisappear()
    }

    public func onError(error: CCPAConsentViewControllerError?) {
        loading = .Ready
        if(shouldCleanConsentOnError) {
            clearAllConsentData()
        }
        consentDelegate?.onError?(error: error)
    }

    public func onAction(_ action: Action) {
        if(action == .AcceptAll || action == .RejectAll || action == .PMAction) {
            sourcePoint.postAction(action: action, consentUUID: consentUUID) { [weak self] response in
                self?.getConsents(forUUID: response.uuid, consentString: response.ccpaString)
            }
        }
    }
    
    public func onConsentReady(consentUUID: UUID, consents: [Consent], consentString: CCPAString?) {
        guard let consentString = consentString else {
            consentDelegate?.onConsentReady?(consentUUID: consentUUID, consents: consents, consentString: nil)
            return
        }
        self.consentUUID = consentUUID
        ccpaString = consentString
        UserDefaults.standard.setValue(consentString, forKey: CCPAConsentViewController.CCPA_CONSENT_KEY)
        UserDefaults.standard.setValue(consentUUID.uuidString, forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        UserDefaults.standard.synchronize()
        consentDelegate?.onConsentReady?(consentUUID: consentUUID, consents: consents, consentString: consentString)
    }

    public func messageWillShow() { consentDelegate?.messageWillShow?() }
    public func messageDidDisappear() { consentDelegate?.messageDidDisappear?() }
    public func pmWillShow() { consentDelegate?.pmWillShow?() }
    public func pmDidDisappear() { consentDelegate?.pmDidDisappear?() }
}
