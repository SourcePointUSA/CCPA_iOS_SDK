//
//  ViewController.swift
//  Example
//
//  Created by Andre Herculano on 15.05.19.
//  Copyright © 2019 sourcepoint. All rights reserved.
//

import UIKit
import CCPAConsentViewController
import ConsentViewController

class ViewController: UIViewController {
    lazy var ccpa: CCPAConsentViewController = { CCPAConsentViewController(
        accountId: 22,
        propertyId: 7480,
        propertyName: try! PropertyName("twosdks.demo"),
        PMId: "5e6a7f997653402334162542",
        campaignEnv: .Public,
        targetingParams: ["SDK_TYPE":"CCPA"],
        consentDelegate: self
    )}()

    lazy var gdpr: GDPRConsentViewController = { GDPRConsentViewController(
        accountId: 22,
        propertyId: 7480,
        propertyName: try! GDPRPropertyName("twosdks.demo"),
        PMId: "227349",
        campaignEnv: .Public,
        targetingParams: ["SDK_TYPE":"GDPR"],
        consentDelegate: self
    )}()

    @IBAction func onPrivacySettingsTap(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "ccpaApplies") {
            ccpa.loadMessage()
        } else if UserDefaults.standard.bool(forKey: "IABTCF_gdprApplies") {
            gdpr.loadMessage()
        } else {
            print("No privacy legislation applies.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // load both SDKs at the app launch
        ccpa.loadMessage()
        gdpr.loadMessage()
    }

    func consentUIDidDisappear() {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController:  ConsentDelegate {
    func ccpaConsentUIWillShow() {
        present(ccpa, animated: true, completion: nil)
    }

    func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        print("-- CCPA --")
        print("consentUUID:", consentUUID)
        print("userConsents:", userConsent)
    }

    @nonobjc func onError(error: CCPAConsentViewControllerError?) {
        print("CCPA Error:", error?.description ?? "Something Went Wrong")
    }
}

extension ViewController: GDPRConsentDelegate {
    func gdprConsentUIWillShow() {
        present(gdpr, animated: true, completion: nil)
    }

    func onConsentReady(gdprUUID: GDPRUUID, userConsent: GDPRUserConsent) {
        print("-- GDPR --")
        print("gdprUUID:", gdprUUID)
        print("userConsents:", userConsent)
    }

    @nonobjc func onError(error: GDPRConsentViewControllerError?) {
        print("GDPR Error:", error?.description ?? "Something Went Wrong")
    }
}
