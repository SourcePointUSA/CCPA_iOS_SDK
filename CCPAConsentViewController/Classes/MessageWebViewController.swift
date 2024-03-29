//
//  MessageWebViewController.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 05.12.19.
//

import UIKit
import WebKit

/**
 MessageWebViewController is responsible for loading the consent message and privacy manager through a webview.
 
 It not only knows how to render the message and pm but also understands how to react to their different events (showing, user action, etc)
 */
class MessageWebViewController: MessageViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, ConsentDelegate {
    static let MESSAGE_HANDLER_NAME = "JSReceiver"

    lazy var webview: WKWebView? = {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        guard let path = Bundle.framework.path(forResource: Self.MESSAGE_HANDLER_NAME, ofType: "js"),
              let scriptSource = try? String(contentsOfFile: path)
        else {
            consentDelegate?.onError?(ccpaError: CCPAUnableToLoadJSReceiver())
            return nil
        }
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        userContentController.add(self, name: MessageWebViewController.MESSAGE_HANDLER_NAME)
        config.userContentController = userContentController
        let wv = WKWebView(frame: .zero, configuration: config)
        if #available(iOS 11.0, *) {
            wv.scrollView.contentInsetAdjustmentBehavior = .never
        }
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.translatesAutoresizingMaskIntoConstraints = true
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()

    let propertyId: Int
    let pmId: String
    let consentUUID: ConsentUUID?
    let userConsent: UserConsent

    var consentUILoaded = false
    var isPMLoaded = false

    init(propertyId: Int, pmId: String, consentUUID: ConsentUUID?, userConsent: UserConsent) {
        self.propertyId = propertyId
        self.pmId = pmId
        self.consentUUID = consentUUID
        self.userConsent = userConsent
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webview
    }

    func ccpaConsentUIWillShow() {
        if !consentUILoaded {
            consentUILoaded = true
            consentDelegate?.ccpaConsentUIWillShow?()
        }
    }

    func onMessageReady() {
        ccpaConsentUIWillShow()
        consentDelegate?.messageWillShow?()
    }

    func onPMReady() {
        ccpaConsentUIWillShow()
        consentDelegate?.ccpaPMWillShow?()
        isPMLoaded = true
    }

    func closePrivacyManager() {
        isPMLoaded = false
        consentDelegate?.ccpaPMDidDisappear?()
    }

    func closeMessage() {
        consentDelegate?.messageDidDisappear?()
    }

    func closeConsentUIIfOpen() {
        isPMLoaded ? closePrivacyManager() : closeMessage()
        if consentUILoaded { consentUIDidDisappear() }
    }

    func consentUIDidDisappear() {
        consentDelegate?.consentUIDidDisappear?()
    }

    func onError(error: CCPAConsentViewControllerError?) {
        consentDelegate?.onError?(ccpaError: error)
        closeConsentUIIfOpen()
    }

    func showPrivacyManagerFromMessageAction() {
        closeMessage()
        loadPrivacyManager()
    }

    private func onConsentReady() {
        consentDelegate?.onConsentReady?(consentUUID: consentUUID ?? "", userConsent: userConsent)
        closeConsentUIIfOpen()
    }

    func cancelPMAction() {
        (webview?.canGoBack ?? false) ?
            goBackAndClosePrivacyManager():
            onConsentReady()
    }

    func goBackAndClosePrivacyManager() {
        webview?.goBack()
        closePrivacyManager()
        onMessageReady()
    }

    func onAction(_ action: Action, consents: PMConsents?) {
        consentDelegate?.onAction?(action, consents: consents)
        switch action.type {
        case .ShowPrivacyManager:
            showPrivacyManagerFromMessageAction()
        case .Dismiss:
            cancelPMAction()
        default:
            closeConsentUIIfOpen()
        }
    }

    func load(url: URL) {
        let connectvityManager = ConnectivityManager()
        if connectvityManager.isConnectedToNetwork() {
            webview?.load(URLRequest(url: url))
        } else {
            onError(error: CCPANoInternetConnection())
        }
    }

    override func loadMessage(fromUrl url: URL) {
        load(url: url)
    }

    // swiftlint:disable line_length
    func pmUrl() -> URL? {
        return URL(string: "https://ccpa-inapp-pm.sp-prod.net/?privacy_manager_id=\(pmId)&site_id=\(propertyId)&ccpa_origin=https://ccpa-service.sp-prod.net&ccpaUUID=\(consentUUID ?? "")")
    }

    override func loadPrivacyManager() {
        guard let url = pmUrl() else {
            onError(error: CCPAURLParsingError(urlString: "PMUrl"))
            return
        }
        load(url: url)
    }

    /// :nodoc:
    // handles links with "target=_blank", forcing them to open in Safari
    // swiftlint:disable:next line_length
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else { return nil }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        return nil
    }

    func getPMConsentsIfAny(_ payload: [String: Any]) -> PMConsents {
        guard
            let consents = payload["consents"] as? [String: Any],
            let vendors = consents["vendors"] as? [String: Any],
            let purposes = consents["categories"] as? [String: Any],
            let acceptedVendors = vendors["accepted"] as? [String],
            let rejectedVendors = vendors["rejected"] as? [String],
            let acceptedPurposes = purposes["accepted"] as? [String],
            let rejectedPurposes = purposes["rejected"] as? [String]
        else {
            return PMConsents(
                vendors: PMConsent(accepted: [], rejected: []),
                categories: PMConsent(accepted: [], rejected: [])
            )
        }
        return PMConsents(
            vendors: PMConsent(accepted: acceptedVendors, rejected: rejectedVendors),
            categories: PMConsent(accepted: acceptedPurposes, rejected: rejectedPurposes)
        )
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any?],
            let name = body["name"] as? String
        else {
            onError(error: CCPAMessageEventParsingError(message: Optional(message.body).debugDescription))
            return
        }

        switch name {
        case "onMessageReady":
                onMessageReady()
        case "onPMReady":
                onPMReady()
        case "onAction":
            guard
                let payload = body["body"] as? [String: Any],
                let typeString = payload["type"] as? Int,
                let actionType = ActionType(rawValue: typeString)
            else {
                onError(error: CCPAMessageEventParsingError(message: Optional(message.body).debugDescription))
                return
            }
            onAction(Action(type: actionType), consents: getPMConsentsIfAny(payload))
        case "onError":
            onError(error: CCPAWebViewError())
        default:
            print(message.body)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        consentDelegate = nil
        if let contentController = webview?.configuration.userContentController {
        contentController.removeScriptMessageHandler(forName: MessageWebViewController.MESSAGE_HANDLER_NAME)
        contentController.removeAllUserScripts()
        }
    }
}
