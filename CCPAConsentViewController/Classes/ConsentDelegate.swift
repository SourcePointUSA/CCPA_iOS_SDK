//
//  ConsentDelegate.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 11.12.19.
//

import Foundation

@objc public protocol ConsentDelegate {
    @objc func consentUIWillShow()
    @objc optional func messageWillShow()
    @objc optional func pmWillShow()
    @objc optional func pmDidDisappear()
    @objc optional func messageDidDisappear()
    @objc optional func onAction(_ action: Action, consents: PMConsents?)
    @objc func consentUIDidDisappear()
    @objc optional func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent)
    @objc optional func onError(error: CCPAConsentViewControllerError?)
}
