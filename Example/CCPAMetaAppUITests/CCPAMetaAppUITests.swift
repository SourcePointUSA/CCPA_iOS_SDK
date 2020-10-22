//
//  CCPAMetaAppUITests.swift
//  CCPAMetaAppUITests
//
//  Created by Vrushali Deshpande on 10/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import XCTest
import Quick
import Nimble
@testable import CCPA_MetaApp

class CCPAMetaAppUITests: QuickSpec {
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
        
        it("Reject all from Message") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.tap()
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
        }
        
        it("Reject all from Privacy Manager") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue: self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.tap()
            expect(self.app.consentMessage).to(showUp())
        }
        
        it("Save And Exit from Privacy Manager") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.checkConsentedToAll).to(showUp())
        }
        
        it("Cancel from Privacy Manager") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmCancel.tap()
            expect(self.app.consentMessage).to(showUp())
        }
        
        it("Check Save And Exit from Direct Privacy Manager") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.showPMButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.rejectedVendors).to(showUp())
            expect(self.app.rejectedCategories).to(showUp())
        }
        
        it("Check Cancel from Direct Privacy Manager") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.showPMButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmCancel.tap()
            expect(self.app.consentMessage).notTo(showUp())
            expect(self.app.noConsentDisplayed).to(showUp())
        }
        
        it("Dismiss message"){
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.dismissMessage.tap()
            expect(self.app.propertyDebugInfo).to(showUp())
        }
        
        it("Show Message Once") {
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKeyShowOnce, targetingValue:self.properyData.targetingValueShowOnce)
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmSaveAndExit.tap()
            expect(self.app.rejectedVendors).notTo(showUp())
        }
        
        it("Reset Consent Data And Check For Message With Show Message Once"){
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKeyShowOnce, targetingValue:self.properyData.targetingValueShowOnce)
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            self.app.propertyItem.tap()
            expect(self.app.showOnceConsentMessage).notTo(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.swipeLeft()
            self.app.resetPropertyButton.tap()
            self.app.alertYesButton.tap()
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
        }
        
        it("Check Consent Data After No Reset With Show Message Always"){
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.swipeLeft()
            self.app.resetPropertyButton.tap()
            self.app.alertNoButton.tap()
            self.app.propertyItem.tap()
            expect(self.app.consentMessage).to(showUp())
        }
        
        it("Delete Property"){
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.pmRejectAll.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.swipeLeft()
            self.app.deletePropertyButton.tap()
            self.app.alertNoButton.tap()
            self.app.propertyItem.swipeLeft()
            self.app.deletePropertyButton.tap()
            self.app.alertYesButton.tap()
            expect(self.app.propertyItem).notTo(showUp())
        }
        
        it("Check Message After Edit Property"){
            self.app.addPropertyDetails()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.targetingCAValue)
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.noConsentDisplayed).to(showUp())
            self.app.backButton.tap()
            expect(self.app.propertyList).to(showUp())
            self.app.propertyItem.swipeLeft()
            self.app.editPropertyButton.tap()
            self.app.addTargetingParameter(targetingKey: self.properyData.targetingKey, targetingValue:self.properyData.valueParamUSRegion)
            expect(self.app.showOnceConsentMessage).to(showUp())
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
        }
    }
}
