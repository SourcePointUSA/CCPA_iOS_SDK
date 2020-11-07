//
//  AuthIdTests.swift
//  CCPAMetaAppUITests
//
//  Created by Vrushali Deshpande on 10/19/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import XCTest
import Quick
import Nimble
@testable import CCPA_MetaApp

class AuthIdTests: QuickSpec {
    var app: CCPAMetaApp!
    var properyData = CCPAPropertyData()
    
    override func spec() {
        beforeSuite {
            self.continueAfterFailure = false
            self.app = CCPAMetaApp()
            Nimble.AsyncDefaults.Timeout = 20
            Nimble.AsyncDefaults.PollInterval = 0.5
        }
        
        afterSuite {
            Nimble.AsyncDefaults.Timeout = 1
            Nimble.AsyncDefaults.PollInterval = 0.01
        }
        
        beforeEach {
            self.app.relaunch(clean: true)
        }
        
        func addAuthID() {
            self.app.authIdTextFieldOutlet.tap()
            self.app.authIdTextFieldOutlet.typeText(self.app.dateFormatterForAuthID())
        }
        
        it("No Message shown with show once criteria when consent already saved with AuthID") {
            self.app.addPropertyDetails()
            addAuthID()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKeyShowOnce, targetingValue: self.properyData.targetingValueShowOnce)
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.checkConsentedToAll).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            if self.app.propertyItem.exists {
                self.app.propertyItem.swipeLeft()
                self.app.resetPropertyButton.tap()
                if self.app.alertYesButton.exists {
                    self.app.alertYesButton.tap()
                }
            }
            expect(self.app.consentMessage).notTo(showUp())
        }

        //Ignore: Unique Identifiers are not defined for toggles present with purposes in PM
        it("Changing AuthID will change the consents too") {
            self.app.addPropertyDetails()
            addAuthID()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.addPropertyButton.tap()
            expect(self.app.newProperty).to(showUp())
            self.app.accountIDTextFieldOutlet.tap()
            self.app.accountIDTextFieldOutlet.typeText(self.properyData.accountId)
            self.app.propertyIdTextFieldOutlet.tap()
            self.app.propertyIdTextFieldOutlet.typeText(self.properyData.propertyId)
            self.app.propertyTextFieldOutlet.tap()
            self.app.propertyTextFieldOutlet.typeText(self.properyData.propertyName)
            addAuthID()
            self.app.pmTextFieldOutlet.tap()
            self.app.pmTextFieldOutlet.typeText(self.properyData.pmID)
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
//            self.app.pmSaveAndExit.tap()
//            expect(self.app.noConsentDisplayed).to(showUp())
        }
        
        it("Check consents with same AuthID after deleting and recreating property") {
            self.app.addPropertyDetails()
            let authID = self.app.dateFormatterForAuthID()
            self.app.authIdTextFieldOutlet.tap()
            self.app.authIdTextFieldOutlet.typeText(authID)
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
            self.app.backButton.tap()
            self.app.addPropertyDetails()
            self.app.authIdTextFieldOutlet.tap()
            self.app.authIdTextFieldOutlet.typeText(authID)
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.rejectedVendors).to(showUp())
        }
        
        it("When consents already given then Message will not appear with AuthID and consents will attach with AuthID") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKeyShowOnce, targetingValue: self.properyData.targetingValueShowOnce)
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            self.app.pmSaveAndExit.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            if self.app.propertyItem.exists {
                self.app.propertyItem.swipeLeft()
                self.app.editPropertyButton.tap()
                expect(self.app.editProperty).to(showUp())
                addAuthID()
                self.app.savePropertyButton.tap()
                expect(self.app.propertyDebugInfo).to(showUp())
            }
        }
        
        it("Check Consents With Authentication To Show Message Always"){
            self.app.addPropertyDetails()
            addAuthID()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
            expect(self.app.checkConsentedToAll).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.tap()
            expect(self.app.consentMessage).to(showUp())
        }
    }
    
}
