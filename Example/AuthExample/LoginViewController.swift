//
//  LoginViewController.swift
//  AuthExample
//
//  Created by Andre Herculano on 19.06.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CCPAConsentViewController

class LoginViewController: UIViewController, UITextFieldDelegate, ConsentDelegate {
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var authIdField: UITextField!
    @IBOutlet var consentTableView: UITableView!

    lazy var consentViewController = {
        return CCPAConsentViewController(accountId: 22, propertyId: 6099, propertyName: try! PropertyName("ccpa.mobile.demo"), PMId: "5df9105bcf42027ce707bb43", campaignEnv: .Public, consentDelegate: self)
    }()

    let tableSections = ["ConsentUUID", "Rejected consents"]
    var consentUUID: String?
    var userConsents: UserConsent?

    @IBAction func onUserNameChanged(_ sender: UITextField) {
        let userName = sender.text ?? ""
        loginButton.isEnabled = userName.trimmingCharacters(in: .whitespacesAndNewlines) != ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let userName = textField.text ?? ""
        if userName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            loginButton.sendActions(for: .touchUpInside)
            return true
        }
        return false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

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

    @IBAction func onSettingsPress(_ sender: Any) {
        initData()
        consentViewController.loadPrivacyManager()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        consentViewController.loadMessage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let homeController = segue.destination as? HomeViewController
        homeController?.authId = authIdField.text!
        resetView()
    }

    func resetView() {
        authIdField.text = nil
        loginButton.isEnabled = false
    }
}

extension LoginViewController: UITableViewDataSource {
    func initData() {
        self.consentUUID = "consentUUID: loading..."
        consentTableView.reloadData()
    }

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
            break
        case 1:
            let consent = userConsents?.rejectedVendors[indexPath.row]
            cell.textLabel?.adjustsFontSizeToFitWidth = false
            cell.textLabel?.font = UIFont.systemFont(ofSize: 8)
            if let consentID = consent {
                cell.textLabel?.text = "Vendor ID: \(consentID))"
            }
            break
        default:
            break
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
}
