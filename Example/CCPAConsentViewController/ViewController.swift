//
//  ViewController.swift
//  Example
//
//  Created by Andre Herculano on 15.05.19.
//  Copyright © 2019 sourcepoint. All rights reserved.
//

import UIKit
import CCPAConsentViewController

class ViewController: UIViewController {

    let logger = Logger()

    lazy var consentViewController: CCPAConsentViewController = { return CCPAConsentViewController(
        accountId: 22,
        propertyId: 6099,
        propertyName: try! PropertyName("ccpa.mobile.demo"),
        PMId: "5df9105bcf42027ce707bb43",
        campaignEnv: .Public,
        consentDelegate: self
    )}()

    @IBAction func onPrivacySettingsTap(_ sender: Any) {
        consentViewController.loadPrivacyManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        consentViewController.loadMessage()
    }
}

extension ViewController: ConsentDelegate {
    func ccpaConsentUIWillShow() {
        present(consentViewController, animated: true, completion: nil)
    }

    func consentUIDidDisappear() {
        dismiss(animated: true, completion: nil)
    }

    func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        print("consentUUID: \(consentUUID)")
        print("userConsents: \(userConsent)")
    }

    func onError(error: CCPAConsentViewControllerError?) {
        logger.log("Error: %{public}@", [error?.description ?? "Something Went Wrong"])
    }
}

