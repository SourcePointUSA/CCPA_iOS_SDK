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
        return CCPAConsentViewController(accountId: 22, propertyId: 2372, property: "mobile.demo", PMId: "5c0e81b7d74b3c30c6852301", campaign: "stage", consentDelegate: self)
    }()
    
    let tableSections = ["userData", "consents"]
    var userData: [String] = []
    var consents:[Consent] = []

    @IBAction func onUserNameChanged(_ sender: UITextField) {
        let userName = sender.text ?? ""
        loginButton.isEnabled = userName.trimmingCharacters(in: .whitespacesAndNewlines) != ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let userName = textField.text ?? ""
        if(userName.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            loginButton.sendActions(for: .touchUpInside)
            return true
        }
        return false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func consentUIWillShow() {
        self.present(consentViewController, animated: true, completion: nil)
    }
    
    func consentUIDidDisappear() {
        self.dismiss(animated: true, completion: nil)
    }

    func onConsentReady(consentUUID: UUID, consents: [Consent], consentString: ConsentString?) {
        self.userData = [
            "consentUUID: \(consentUUID.uuidString)",
            "euconsent: \(consentString?.consentString ?? "<unknown>")"
        ]
        self.consents = consents
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
        self.userData = [
            "consentUUID: loading...",
            "euconsent: loading..."
        ]
        consentTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return userData.count
        case 1:
            return consents.count
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
            cell.textLabel?.text = userData[indexPath.row]
            break
        case 1:
            let consent = consents[indexPath.row]
            cell.textLabel?.adjustsFontSizeToFitWidth = false
            cell.textLabel?.font = UIFont.systemFont(ofSize: 8)
            cell.textLabel?.text = "\(type(of: consent)) \(consent.name)"
            break
        default:
            break
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
}

