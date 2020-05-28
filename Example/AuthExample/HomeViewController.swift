//
//  HomeViewController.swift
//  AuthExample
//
//  Created by Andre Herculano on 19.06.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CCPAConsentViewController

class HomeViewController: UIViewController, ConsentDelegate {
    lazy var consentViewController = {
        return CCPAConsentViewController(accountId: 22, propertyId: 6099, propertyName: try! PropertyName("ccpa.mobile.demo"), PMId: "5df9105bcf42027ce707bb43", campaignEnv: .Public, consentDelegate: self)
    }()

    var authId = ""
    var consentUUID: String?

    @IBOutlet var authIdLabel: UILabel!
    @IBOutlet var consentTableView: UITableView!

    let tableSections = ["ConsentUUID", "Rejected consents"]
    var userConsents: UserConsent?

    func ccpaConsentUIWillShow() {
        self.present(consentViewController, animated: true, completion: nil)
    }

    func consentUIDidDisappear() {
        self.dismiss(animated: true, completion: nil)
    }

    func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        self.consentUUID = consentUUID
        self.userConsents = userConsent
        self.consentTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authIdLabel.text = authId
        initData()
        consentViewController.loadMessage() // TODO: implement authID
    }

    @IBAction func onSettingsPress(_ sender: Any) {
        initData()
        consentViewController.loadPrivacyManager() // TODO: implement authID
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return userConsents?.rejectedVendors.count ?? 0
        default:
            return 0
        }
    }

    func initData() {
        self.consentUUID = "consentUUID: loading..."

        consentTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlainCell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = self.consentUUID
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            break
        case 1:
            let consent = userConsents?.rejectedVendors[indexPath.row]
            cell.textLabel?.adjustsFontSizeToFitWidth = false
            cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
            if let consentID = consent {
                cell.textLabel?.text = "Vendor ID: \(consentID))"
            }
            break
        default:
            break
        }
        return cell
    }
}
