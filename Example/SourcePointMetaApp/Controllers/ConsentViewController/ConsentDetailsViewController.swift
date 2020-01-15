//
//  ConsentViewDetailsViewController.swift
//  SourcePointMetaApp
//
//  Created by Vilas on 6/11/19.
//  Copyright © 2019 Cybage. All rights reserved.
//

import UIKit
import CCPAConsentViewController
import CoreData
import WebKit

class ConsentDetailsViewController: BaseViewController, WKNavigationDelegate, ConsentDelegate {
    
    @IBOutlet weak var euConsentLabel: UILabel!
    @IBOutlet weak var consentUUIDLabel: UILabel!
    @IBOutlet weak var consentTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    //// MARK: - Instance properties
    private let cellIdentifier = "ConsentCell"
    
    // Reference to the selected property managed object ID
    var propertyManagedObjectID : NSManagedObjectID?
    
    var userConsents: UserConsent?
    let sections = ["Vendor Consents", "Purpose Consents"]
    
    // MARK: - Initializer
    let addpropertyViewModel: AddPropertyViewModel = AddPropertyViewModel()
    
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consentTableView.tableFooterView = UIView(frame: .zero)
        self.navigationItem.hidesBackButton = true
        navigationSetup()
        setTableViewHidden()
        setconsentIdFromUserDefaults()
        
        if let _propertyManagedObjectID = propertyManagedObjectID {
            self.showIndicator()
            fetchDataFromDatabase(propertyManagedObjectID: _propertyManagedObjectID, completionHandler: {(propertyDetails, targetingParamsArray) in
                self.loadConsentManager(propertyDetails: propertyDetails, targetingParamsArray: targetingParamsArray)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setconsentIdFromUserDefaults()
    }
    
    func navigationSetup() {
        
        let backIcon = UIButton(frame: CGRect.zero)
        backIcon.setImage(UIImage(named: "Back"), for: UIControl.State())
        backIcon.addTarget(self, action: #selector(back), for: UIControl.Event.touchUpInside)
        let backIconBarButton : UIBarButtonItem = UIBarButtonItem(customView: backIcon)
        backIcon.sizeToFit()
        self.navigationItem.leftBarButtonItem = backIconBarButton
    }
    
    @objc func back() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setTableViewHidden() {
//        consentTableView.isHidden = !(userConsents()
//        noDataLabel.isHidden = userConsents.count > 0
    }
    
    func setconsentIdFromUserDefaults() {
        if let consentID = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY),consentID.count > 0 {
            consentUUIDLabel.text = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
            euConsentLabel.text = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        }else {
            consentUUIDLabel.text = SPLiteral.consentUUID
            euConsentLabel.text = SPLiteral.euConsentID
        }
    }
    
    func fetchDataFromDatabase(propertyManagedObjectID : NSManagedObjectID, completionHandler: @escaping (PropertyDetailsModel, [TargetingParamModel]) -> Void)  {
        self.addpropertyViewModel.fetch(property: propertyManagedObjectID, completionHandler: {( propertyDataModel) in
            let propertyDetail = PropertyDetailsModel(accountId: propertyDataModel.accountId, propertyId: propertyDataModel.propertyId, propertyName: propertyDataModel.propertyName, campaign: propertyDataModel.campaign, privacyManagerId: propertyDataModel.privacyManagerId, creationTimestamp: propertyDataModel.creationTimestamp! ,authId: propertyDataModel.authId)
            var targetingParamsArray = [TargetingParamModel]()
            if let targetingParams = propertyDataModel.manyTargetingParams?.allObjects as! [TargetingParams]? {
                for targetingParam in targetingParams {
                    let targetingParamModel = TargetingParamModel(targetingParamKey: targetingParam.key, targetingParamValue: targetingParam.value)
                    targetingParamsArray.append(targetingParamModel)
                }
            }
            completionHandler(propertyDetail, targetingParamsArray)
        })
    }
    
    func loadConsentManager(propertyDetails : PropertyDetailsModel, targetingParamsArray:[TargetingParamModel]) {
            
        let consentViewController =  CCPAConsentViewController(accountId: Int(propertyDetails.accountId), propertyId: Int(propertyDetails.propertyId), propertyName: try! PropertyName(propertyDetails.propertyName!), PMId: propertyDetails.privacyManagerId!, campaignEnv: .Public, consentDelegate: self)
        consentViewController.loadMessage()
           
//            if let authId = propertyDetails.authId {
//                consentViewController.loadMessage(forAuthId: authId)
//                consentViewController.loadMessage()
//            }else {
//                consentViewController.loadMessage()
//            }
    }
    func consentUIWillShow() {
           hideIndicator()
//           present(self.consentViewController!, animated: true, completion: nil)
       }

       func consentUIDidDisappear() {
           dismiss(animated: true, completion: nil)
       }
    
    func onMessageReady(controller: CCPAConsentViewController) {
        self.hideIndicator()
    }
    
    func onErrorOccurred(error: CCPAConsentViewControllerError) {
        logger.log("Error: %{public}@", [error])
        self.hideIndicator()
        let okHandler = {
            self.dismiss(animated: false, completion: nil)
        }
        AlertView.sharedInstance.showAlertView(title: Alert.message, message: error.description, actions: [okHandler], titles: [Alert.ok], actionStyle: UIAlertController.Style.alert)
    }
    
    
    func loadConsentInfoController(vendorConsents : UserConsent ) {
        self.hideIndicator()
        
        if let consentViewDetailsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConsentDetailsViewController") as? ConsentDetailsViewController {
                consentViewDetailsController.userConsents = vendorConsents
            self.navigationController?.pushViewController(consentViewDetailsController, animated: true)
        }
    }
    
    func refreshTableViewWithConsentInfo(vendorConsents : UserConsent) {
        self.userConsents = vendorConsents
        self.consentTableView.reloadData()
    }
    
    @IBAction func showPMAction(_ sender: Any) {
    }
    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

//// MARK: UITableViewDataSource
extension ConsentDetailsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = #colorLiteral(red: 0.2841853499, green: 0.822665453, blue: 0.653732717, alpha: 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConsentTableViewCell {
            if indexPath.section == 0 {
//                cell.consentIDString.text = vendorConsents[indexPath.row].id
//                cell.consentNameString.text = vendorConsents[indexPath.row].name
            } else {
//                cell.consentIDString.text = purposeConsents[indexPath.row].id
//                cell.consentNameString.text = purposeConsents[indexPath.row].name
            }
            return cell
        }
        return UITableViewCell()
    }
}

//// MARK: - UITableViewDelegate
extension ConsentDetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        consentTableView.deselectRow(at: indexPath, animated: false)
    }
}
