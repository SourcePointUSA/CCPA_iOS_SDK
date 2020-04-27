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
        guard let scriptSource = try? String(
            contentsOfFile: Bundle(for: CCPAConsentViewController.self).path(forResource:
                MessageWebViewController.MESSAGE_HANDLER_NAME, ofType: "js")!)
            else {
                consentDelegate?.onError?(error: UnableToLoadJSReceiver())
                return nil
        }
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        userContentController.addUserScript(self.disableZoomInScrollView())
        userContentController.add(self, name: MessageWebViewController.MESSAGE_HANDLER_NAME)
        config.userContentController = userContentController
        let wv = WKWebView(frame: .zero, configuration: config)
        if #available(iOS 11.0, *) {
            wv.scrollView.contentInsetAdjustmentBehavior = .never;
        }
        wv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wv.translatesAutoresizingMaskIntoConstraints = true
        wv.uiDelegate = self
        wv.navigationDelegate = self
        wv.scrollView.delegate = self
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.allowsBackForwardNavigationGestures = true
        return wv
    }()
    
    let propertyId: Int
    let pmId: String
    let consentUUID: ConsentUUID?
    
    var consentUILoaded = false
    var isPMLoaded = false
    
    init(propertyId: Int, pmId: String, consentUUID: ConsentUUID?) {
        self.propertyId = propertyId
        self.pmId = pmId
        self.consentUUID = consentUUID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webview
    }
    
    func ccpaConsentUIWillShow() {
        if(!consentUILoaded) {
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
        consentDelegate?.onError?(error: error)
        closeConsentUIIfOpen()
    }

    func showPrivacyManagerFromMessageAction() {
        closeMessage()
        loadPrivacyManager()
    }

    func cancelPMAction() {
        (webview?.canGoBack ?? false) ?
            goBackAndClosePrivacyManager():
            closeConsentUIIfOpen()
    }

    func goBackAndClosePrivacyManager() {
        webview?.goBack()
        closePrivacyManager()
        onMessageReady()
    }

    func onAction(_ action: Action, consents: PMConsents?) {
        consentDelegate?.onAction?(action, consents: consents)
        switch action {
        case .ShowPrivacyManager:
            showPrivacyManagerFromMessageAction()
        case .Dismiss:
            cancelPMAction()
        default:
            closeConsentUIIfOpen()
        }
    }

    func load(url: URL) {
        if ConnectivityManager.shared.isConnectedToNetwork() {
            webview?.load(URLRequest(url: url))
        } else {
            onError(error: NoInternetConnection())
        }
    }
    
    override func loadMessage(fromUrl url: URL) {
        load(url: url)
    }
    
    func pmUrl() -> URL? {
        return URL(string: "https://ccpa-inapp-pm.sp-prod.net/?privacy_manager_id=\(pmId)&site_id=\(propertyId)&ccpa_origin=https://ccpa-service.sp-prod.net&ccpaUUID=\(consentUUID ?? "")")
    }
    
    override func loadPrivacyManager() {
        guard let url = pmUrl() else {
            onError(error: URLParsingError(urlString: "PMUrl"))
            return
        }
        load(url: url)
    }
    
    /// :nodoc:
    // handles links with "target=_blank", forcing them to open in Safari
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
            onError(error: MessageEventParsingError(message: Optional(message.body).debugDescription))
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
                    let actionType = payload["type"] as? Int,
                    let action = Action(rawValue: actionType)
                else {
                    onError(error: MessageEventParsingError(message: Optional(message.body).debugDescription))
                    return
                }
                onAction(action, consents: getPMConsentsIfAny(payload))
            case "onError":
                onError(error: WebViewError())
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

// we implement this protocol to disable the zoom when the user taps twice on the screen
extension MessageWebViewController: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func disableZoomInScrollView() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
}
