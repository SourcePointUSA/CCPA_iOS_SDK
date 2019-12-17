//
//  ViewController.swift
//  Example
//
//  Created by Andre Herculano on 15.05.19.
//  Copyright © 2019 sourcepoint. All rights reserved.
//

import UIKit
import CCPAConsentViewController

class ViewController: UIViewController, ConsentDelegate {
    let logger = Logger()

    lazy var consentViewController: CCPAConsentViewController = {
        return CCPAConsentViewController(accountId: 22, propertyId: 2372, property: "mobile.demo", PMId: "5c0e81b7d74b3c30c6852301", campaign: "stage", consentDelegate: self)
    }()
    
    func consentUIWillShow() {
        present(consentViewController, animated: true, completion: nil)
    }

    func consentUIDidDisappear() {
        dismiss(animated: true, completion: nil)
    }
    
    func onConsentReady(consentUUID: UUID, consents: [Consent], consentString: ConsentString?) {
        consents.forEach({ [weak self] consent in
            self?.logger.log("Consented to: %{public}@)", [consent])
        })
    }

    func onError(error: CCPAConsentViewControllerError?) {
        logger.log("Error: %{public}@", [error?.description ?? "Something Went Wrong"])
    }

    @IBAction func onPrivacySettingsTap(_ sender: Any) {
        consentViewController.loadPrivacyManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        consentViewController.loadMessage()
    }
}

