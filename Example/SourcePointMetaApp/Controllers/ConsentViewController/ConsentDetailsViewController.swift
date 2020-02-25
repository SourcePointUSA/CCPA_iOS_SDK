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
    
    @IBOutlet weak var consentUUIDLabel: UILabel!
    @IBOutlet weak var rejectedConsentsTableView: UITableView!
    @IBOutlet weak var userConsentedToAll: UILabel!
    
    //// MARK: - Instance properties
    private let cellIdentifier = "ConsentCell"
    
    // Reference to the selected property managed object ID
    var propertyManagedObjectID : NSManagedObjectID?
    
    var userConsents: UserConsent?
    let sections = ["Rejected Vendors", "Rejected Categories"]
    
    // MARK: - Initializer
    let addpropertyViewModel: AddPropertyViewModel = AddPropertyViewModel()
    var consentViewController: CCPAConsentViewController?
    var propertyDetails: PropertyDetailsModel?
    var targetingParams = [TargetingParamModel]()
    let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rejectedConsentsTableView.tableFooterView = UIView(frame: .zero)
        self.navigationItem.hidesBackButton = true
        navigationSetup()
        setTableViewHidden()
        setconsentUUIdFromUserDefaults()
        
        if let _propertyManagedObjectID = propertyManagedObjectID {
            self.showIndicator()
            fetchDataFromDatabase(propertyManagedObjectID: _propertyManagedObjectID, completionHandler: {(propertyDetails, targetingParams) in
                self.propertyDetails = propertyDetails
                self.targetingParams = targetingParams
                self.loadConsentManager(propertyDetails: propertyDetails, targetingParams: targetingParams)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setconsentUUIdFromUserDefaults()
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
        if userConsents?.status == ConsentStatus.RejectedSome {
            rejectedConsentsTableView.isHidden = false
            userConsentedToAll.isHidden = true
        }else {
            rejectedConsentsTableView.isHidden = true
            userConsentedToAll.isHidden = false
            if userConsents?.status == ConsentStatus.RejectedAll {
                userConsentedToAll.text = SPLiteral.rejectedAll
            }else {
                userConsentedToAll.text = SPLiteral.rejectedNone
            }
        }
    }
    
    func setconsentUUIdFromUserDefaults() {
        if let consentID = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY),consentID.count > 0 {
            consentUUIDLabel.text = UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
        }else {
            consentUUIDLabel.text = SPLiteral.consentUUID
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
    
    func loadConsentManager(propertyDetails : PropertyDetailsModel, targetingParams:[TargetingParamModel]) {
        let campaign: CampaignEnv = propertyDetails.campaign == 0 ? .Stage : .Public
        var targetingParameters = [String:String]()
        for targetingParam in targetingParams {
            targetingParameters[targetingParam.targetingKey!] = targetingParam.targetingValue
        }
        consentViewController =  CCPAConsentViewController(accountId: Int(propertyDetails.accountId), propertyId: Int(propertyDetails.propertyId), propertyName: try! PropertyName(propertyDetails.propertyName!), PMId: propertyDetails.privacyManagerId!, campaignEnv: campaign, targetingParams:targetingParameters, consentDelegate: self)
        
        //            if let authId = propertyDetails.authId {
        //                consentViewController.loadMessage(forAuthId: authId)
        //            }else {
        //                consentViewController.loadMessage()
        //            }
        consentViewController?.loadMessage()
        
    }
    func consentUIWillShow() {
        hideIndicator()
        present(self.consentViewController!, animated: true, completion: nil)
    }
    
    func consentUIDidDisappear() {
        dismiss(animated: true, completion: nil)
    }
    
    func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        self.showIndicator()
        self.userConsents = userConsent
        setconsentUUIdFromUserDefaults()
        rejectedConsentsTableView.reloadData()
        self.hideIndicator()
    }
    
    func onError(error: CCPAConsentViewControllerError?) {
        logger.log("Error: %{public}@", [error?.description ?? "Something Went Wrong"])
        let okHandler = {
            self.hideIndicator()
            self.dismiss(animated: false, completion: nil)
        }
        AlertView.sharedInstance.showAlertView(title: Alert.message, message: error?.description ?? "Something Went Wrong", actions: [okHandler], titles: [Alert.ok], actionStyle: UIAlertController.Style.alert)
    }
    
    @IBAction func showPMAction(_ sender: Any) {
        self.showIndicator()
        let campaign: CampaignEnv = self.propertyDetails?.campaign == 0 ? .Stage : .Public
        var targetingParameters = [String:String]()
        for targetingParam in targetingParams {
            targetingParameters[targetingParam.targetingKey!] = targetingParam.targetingValue
        }
        consentViewController =  CCPAConsentViewController(accountId: Int(propertyDetails!.accountId), propertyId: Int(propertyDetails!.propertyId), propertyName: try! PropertyName((propertyDetails?.propertyName)!), PMId: (propertyDetails?.privacyManagerId)!, campaignEnv: campaign, targetingParams: targetingParameters, consentDelegate: self)
        consentViewController?.loadPrivacyManager()
    }
}

//// MARK: UITableViewDataSource
extension ConsentDetailsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return sections.count
        }
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sections[section]
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            if let headerView = view as? UITableViewHeaderFooterView {
                headerView.textLabel?.textColor = #colorLiteral(red: 0.2841853499, green: 0.822665453, blue: 0.653732717, alpha: 1)
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            setTableViewHidden()
            if section == 0 {
                return userConsents?.rejectedVendors.count ?? 0
            }else {
                return userConsents?.rejectedCategories.count ?? 0
            }
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConsentTableViewCell {
                if indexPath.section == 0 {
                    cell.rejectedConsentID.text = userConsents?.rejectedVendors[indexPath.row]
                    cell.consentType.text = "Vendor Id: "
                } else {
                    cell.rejectedConsentID.text = userConsents?.rejectedCategories[indexPath.row]
                    cell.consentType.text = "Purpose Id: "
                }
                return cell
            }
            return UITableViewCell()
        }
    }

//// MARK: - UITableViewDelegate
extension ConsentDetailsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        rejectedConsentsTableView.deselectRow(at: indexPath, animated: false)
    }
}
