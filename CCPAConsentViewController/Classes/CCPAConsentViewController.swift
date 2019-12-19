//
//  CCPAConsentViewController.swift
//  cmp-app-test-app
//
//  Created by Andre Herculano on 12/16/19.
//  Copyright © 2019 Sourcepoint. All rights reserved.
//

import UIKit

@objcMembers open class CCPAConsentViewController: UIViewController {
    static public let CCPA_USER_CONSENTS: String = "sp_ccpa_user_consents"
    static public let CONSENT_UUID_KEY: String = "sp_consentUUID"
    static public let META_KEY: String = "sp_meta"

    private let accountId, propertyId: Int
    private let propertyName: PropertyName
    private let pmId: String

    public typealias TargetingParams = [String:String]
    private let targetingParams: TargetingParams = [:]

    private let sourcePoint: SourcePointClient

    private weak var consentDelegate: ConsentDelegate?
    private var messageViewController: MessageViewController?
    
    private enum LoadingStatus: String {
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
    
    /// Contains the `ConsentStatus`, an array of rejected vendor ids and and array of rejected purposes
    public var userConsent: UserConsent

    /// The UUID assigned to a user, available after calling `loadMessage`
    public var consentUUID: ConsentUUID?
    
    /// Instructs the SDK to clean consent data if an error occurs. It's `true` by default.
    public var shouldCleanConsentOnError = true

    /**
        - Parameter accountId: the id of your account, can be found in the Account section of SourcePoint's dashboard
        - Parameter propertyId: the id of your property, can be found in the property page of SourcePoint's dashboard
        - Parameter propertyName: the exact name of your property,
        - Parameter PMId: the id of the PrivacyManager, can be found in the PrivacyManager page of SourcePoint's dashboard
        - Parameter PMId: the id of the PrivacyManager, can be found in the PrivacyManager page of SourcePoint's dashboard
     */
    public init(
        accountId: Int,
        propertyId: Int,
        propertyName: PropertyName,
        PMId: String,
        campaign: String,
        consentDelegate: ConsentDelegate
    ){
        self.accountId = accountId
        self.propertyName = propertyName
        self.propertyId = propertyId
        self.pmId = PMId
        self.consentDelegate = consentDelegate
        if let data = UserDefaults.standard.value(forKey: CCPAConsentViewController.CCPA_USER_CONSENTS) as? Data {
            self.userConsent = (try? PropertyListDecoder().decode(UserConsent.self, from: data)) ?? UserConsent.rejectedNone()
        } else {
            self.userConsent = UserConsent.rejectedNone()
        }
        self.userConsent = (UserDefaults.standard.object(forKey: CCPAConsentViewController.CCPA_USER_CONSENTS) as? UserConsent) ??
            UserConsent(status: .RejectedNone, rejectedVendors: [], rejectedCategories: [])
        self.consentUUID = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        
        self.sourcePoint = SourcePointClient(
            accountId: accountId,
            propertyId: propertyId,
            propertyName: propertyName,
            pmId: PMId,
            campaign: campaign
        )

        super.init(nibName: nil, bundle: nil)
        
        sourcePoint.onError = onError
        
        modalPresentationStyle = .overFullScreen
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadMessage(fromUrl url: URL) {
        messageViewController = MessageWebViewController(propertyId: propertyId, pmId: pmId, consentUUID: consentUUID)
        messageViewController?.consentDelegate = self
        messageViewController?.loadMessage(fromUrl: url)
    }
    
    public func loadMessage() {
        if loading == .Ready {
            loading = .Loading
            sourcePoint.getMessage(consentUUID: consentUUID) { [weak self] message in
                if let url = message.url {
                    self?.loadMessage(fromUrl: url)
                } else {
                    self?.loading = .Ready
                    self?.onConsentReady(consentUUID: message.uuid, userConsent: message.userConsent)
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

    /// Remove all consent related data from the UserDefaults
    public func clearAllConsentData() {
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.CCPA_USER_CONSENTS)
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        UserDefaults.standard.removeObject(forKey: CCPAConsentViewController.META_KEY)
        UserDefaults.standard.synchronize()
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

    public func onAction(_ action: Action, consents: PMConsents?) {
        if(action == .AcceptAll || action == .RejectAll || action == .SaveAndExit) {
            sourcePoint.postAction(action: action, consentUUID: consentUUID, consents: consents) { [weak self] response in
                self?.onConsentReady(consentUUID: response.uuid, userConsent: response.userConsent)
            }
        }
    }
    
    public func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        self.consentUUID = consentUUID
        self.userConsent = userConsent
        UserDefaults.standard.setValue(try? PropertyListEncoder().encode(userConsent), forKey: CCPAConsentViewController.CCPA_USER_CONSENTS)
        UserDefaults.standard.setValue(consentUUID, forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        UserDefaults.standard.synchronize()
        consentDelegate?.onConsentReady?(consentUUID: consentUUID, userConsent: userConsent)
    }

    public func messageWillShow() { consentDelegate?.messageWillShow?() }
    public func messageDidDisappear() { consentDelegate?.messageDidDisappear?() }
    public func pmWillShow() { consentDelegate?.pmWillShow?() }
    public func pmDidDisappear() { consentDelegate?.pmDidDisappear?() }
}
