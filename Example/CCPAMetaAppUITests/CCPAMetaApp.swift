//
//  CCPAMetaApp.swift
//  SPCCPAMetaAppUITests
//
//  Created by Vrushali Deshpande on 10/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Nimble

protocol App {
    func launch()
    func terminate()
    func relaunch(clean: Bool)
}

extension XCUIApplication: App {
    func relaunch(clean: Bool = false) {
        UserDefaults.standard.synchronize()
        self.terminate()
        clean ?
            launchArguments.append("-cleanAppsData") :
            launchArguments.removeAll { $0 == "-cleanAppsData" }
        launch()
    }
}

protocol CCPAUI {
    var consentUI: XCUIElement { get }
    var privacyManagerUI: XCUIElement { get }
}


class CCPAMetaApp: XCUIApplication {
 
    var properyData = CCPAPropertyData()

     var propertyList: XCUIElement {
         staticTexts["Property List"].firstMatch
     }
    
    var newProperty: XCUIElement {
        staticTexts["New Property"].firstMatch
    }
    
    var editProperty: XCUIElement {
        staticTexts["Edit Property"].firstMatch
    }

    var addPropertyButton: XCUIElement {
           buttons["Add"].firstMatch
       }
    
    var accountIDTextFieldOutlet: XCUIElement {
        textFields["accountIDTextFieldOutlet"].firstMatch
    }

    var propertyIdTextFieldOutlet: XCUIElement {
        textFields["propertyIdTextFieldOutlet"].firstMatch
    }

    var propertyTextFieldOutlet: XCUIElement {
        textFields["propertyTextFieldOutlet"].firstMatch
    }

    var authIdTextFieldOutlet: XCUIElement {
        textFields["authIdTextFieldOutlet"].firstMatch
    }
    
    var pmTextFieldOutlet: XCUIElement {
        textFields["pmTextFieldOutlet"].firstMatch
    }
    
    var nativeMessageSwitchOutlet: XCUIElement {
           switches["nativeMessageSwitchOutlet"].firstMatch
       }
    
    var targetingParamKeyTextFieldOutlet: XCUIElement {
        textFields["targetingParamKeyTextFieldOutlet"].firstMatch
    }

    var targetingParamValueTextFieldOutlet: XCUIElement {
        textFields["targetingParamValueTextFieldOutlet"].firstMatch
    }

    var propertyItem: XCUIElement {
        staticTexts.containing(NSPredicate(format: "(label CONTAINS[cd] 'ccpa.automation.testing.com')")).firstMatch
    }
    
    var editPropertyButton: XCUIElement {
        propertyItem.buttons["trailing1"].firstMatch
    }
    
    var deletePropertyButton: XCUIElement {
        propertyItem.buttons["trailing2"].firstMatch
    }
    
    var resetPropertyButton: XCUIElement {
        propertyItem.buttons["trailing0"].firstMatch
    }
    
    var alertYesButton: XCUIElement {
        buttons["YES"].firstMatch
    }

    var alertNoButton: XCUIElement {
        buttons["NO"].firstMatch
    }
    
    var alertOkButton: XCUIElement {
           alerts["alertView"].buttons["OK"].firstMatch
       }
    
    var addTargetingParamButton: XCUIElement {
        buttons["addButton"].firstMatch
    }
    
    var savePropertyButton: XCUIElement {
        navigationBars.buttons["Save"].firstMatch
    }
    
    var propertyFieldValidationItem: XCUIElement {
        staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Please enter property details'")).firstMatch
    }
    
    var targetingParameterValidationItem: XCUIElement {
           staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Please enter targeting parameter key and value'")).firstMatch
    }
    
    var propertyDebugInfo: XCUIElement {
        staticTexts["Property Debug Info"].firstMatch
    }
    
    var noConsentDisplayed: XCUIElement{
        staticTexts["noDataLabel"].firstMatch
    }
    
    var checkConsentedToAll: XCUIElement{
           staticTexts["noDataLabel"].firstMatch
    }
    
    var wrongPropertyIdValidationItem: XCUIElement {
           staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Error parsing response from'")).firstMatch
    }
    
    var wrongPMValidationItem: XCUIElement {
              staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Could not load PM with id'")).firstMatch
    }
    
    var showPMButton: XCUIElement {
           navigationBars.buttons["Show PM"].firstMatch
    }
    
    var backButton: XCUIElement {
        navigationBars.buttons["Back"].firstMatch
    }
    
    var rejectedVendors: XCUIElement{
        staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Rejected Vendors'")).firstMatch
    }
   
    var rejectedCategories: XCUIElement{
           staticTexts.containing(NSPredicate(format: "label CONTAINS[cd] 'Rejected Categories'")).firstMatch
       }
    func addPropertyDetails() {
        deleteProperty()
        expect(self.propertyList).to(showUp())
        self.addPropertyButton.tap()
        expect(self.newProperty).to(showUp())
        self.accountIDTextFieldOutlet.tap()
        self.accountIDTextFieldOutlet.typeText(self.properyData.accountId)
        self.propertyIdTextFieldOutlet.tap()
        self.propertyIdTextFieldOutlet.typeText(self.properyData.propertyId)
        self.propertyTextFieldOutlet.tap()
        self.propertyTextFieldOutlet.typeText(self.properyData.propertyName)
        self.pmTextFieldOutlet.tap()
        self.pmTextFieldOutlet.typeText(self.properyData.pmID)
        
    }
    
    func deleteProperty() {
        expect(self.propertyList).to(showUp())
        if self.propertyItem.exists {
            self.propertyItem.swipeLeft()
            self.deletePropertyButton.tap()
            if self.alertYesButton.exists {
                self.alertYesButton.tap()
            }
        }
    }
    
    func addTargetingParameter(targetingKey : String, targetingValue : String) {
        swipeUp()
        self.targetingParamKeyTextFieldOutlet.tap()
        self.targetingParamKeyTextFieldOutlet.typeText(targetingKey)
        swipeUp()
        self.targetingParamValueTextFieldOutlet.tap()
        self.targetingParamValueTextFieldOutlet.typeText(targetingValue)
        swipeUp()
        self.addTargetingParamButton.tap()
        self.savePropertyButton.tap()
    }
    
    func addPropertyWithWrongPropertyDetails(accountId : String, propertyId : String, propertyName : String, pmId : String) {
        deleteProperty()
        expect(self.propertyList).to(showUp())
        self.addPropertyButton.tap()
        self.accountIDTextFieldOutlet.tap()
        self.accountIDTextFieldOutlet.typeText(accountId)
        self.propertyIdTextFieldOutlet.tap()
        self.propertyIdTextFieldOutlet.typeText(propertyId)
        self.propertyTextFieldOutlet.tap()
        self.propertyTextFieldOutlet.typeText(propertyName)
        self.pmTextFieldOutlet.tap()
        self.pmTextFieldOutlet.typeText(pmId)
        self.savePropertyButton.tap()
    }
    
    func addTargetingParameterWithWrongDetails(targetingKey : String, targetingValue : String) {
        self.targetingParamValueTextFieldOutlet.tap()
        self.targetingParamValueTextFieldOutlet.typeText(targetingValue)
        swipeUp()
        self.addTargetingParamButton.tap()
    }
    
    func dateFormatterForAuthID() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy, h:mm:ss"
        let formattedDateInString = formatter.string(from: date)
        return formattedDateInString
    }
}

extension CCPAMetaApp: CCPAUI {
    var consentUI: XCUIElement {
        webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'TEST CONSENT MESSAGE CALIFORNIA REGION') OR (label CONTAINS[cd] 'Show Only')")).firstMatch
    }
   
    var privacyManagerUI: XCUIElement {
           webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'Privacy Manager')")).firstMatch
       }
    
   var consentMessage: XCUIElement {
        webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'TEST CONSENT MESSAGE CALIFORNIA REGION KEY-VALUE PAIR')")).firstMatch
    }

    var showOnceConsentMessage: XCUIElement {
           webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'SHOW ONLY ONCE MESSAGE')")).firstMatch
       }
    
    var privacyManager: XCUIElement {
           webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'Privacy Manager')")).firstMatch
       }
    
    var rejectAllButton: XCUIElement {
        consentUI.buttons.containing(NSPredicate(format: "label CONTAINS[cd] 'Reject'")).firstMatch
    }
    
    var privacySettingsButton: XCUIElement {
        consentUI.buttons.containing(NSPredicate(format: "label CONTAINS[cd] 'Privacy Settings'")).firstMatch
    }
    
    var pmRejectAll: XCUIElement{
        staticTexts["Reject All"].firstMatch
    }
    
    var pmSaveAndExit: XCUIElement{
        privacyManagerUI.buttons["Save & Exit"].firstMatch
       }
    
    var pmAcceptAll: XCUIElement{
     staticTexts["Accept All"].firstMatch
    }
    
    var pmCancel: XCUIElement{
     privacyManagerUI.buttons["Cancel"].firstMatch
    }
        
    var dismissMessage: XCUIElement {
        staticTexts["X"].firstMatch
    }
}





