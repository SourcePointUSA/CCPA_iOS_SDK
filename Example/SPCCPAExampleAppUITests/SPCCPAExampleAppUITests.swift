//
//  SPCCPAExampleAppUITests.swift
//  SPCCPAExampleAppUITests
//
//  Created by Vrushali Deshpande on 28/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import Quick
import Nimble

@testable import CCPAConsentViewController_Example

class SPCCPAExampleAppUITests: QuickSpec {
    var app: ExampleApp!
    
    override func spec() {
        beforeSuite {
            self.continueAfterFailure = false
            self.app = ExampleApp()
            Nimble.AsyncDefaults.Timeout = 30
            Nimble.AsyncDefaults.PollInterval = 0.5
        }
        
        afterSuite {
            Nimble.AsyncDefaults.Timeout = 1
            Nimble.AsyncDefaults.PollInterval = 0.01
        }
        
        beforeEach {
            self.app.relaunch(clean: true)
        }
        
        it("Accept all through message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.acceptAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }
        
        it("Reject all through message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.rejectAllButton.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }
        
        it("Reject All through privacy manager via message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.settings.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.rejectAll.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }
        
        it("Save and Exit through privacy manager via message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.acceptAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.saveAndExitButton.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).notTo(showUp())
        }
        
        it("Reject all through the Privacy Manager directly") {
            expect(self.app.consentMessage).to(showUp())
            self.app.acceptAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.rejectAll.tap()
            expect(self.app.privacyManager).to(disappear())
        }
        
        it("Save And Exit through the Privacy Manager directly") {
            expect(self.app.consentMessage).to(showUp())
            self.app.acceptAllButton.tap()
            self.app.privacySettingsButton.tap()
            expect(self.app.privacyManager).to(showUp())
            self.app.saveAndExitButton.tap()
            expect(self.app.privacyManager).to(disappear())
        }
        
//      Ignore: Unique Identifiers are not defined for toggles present with purposes in PM
//        it("Save And Exit with few purposes through the Privacy Manager directly") {
//            expect(self.app.consentMessage).to(showUp())
//            self.app.acceptAllButton.tap()
//            self.app.privacySettingsButton.tap()
//            expect(self.app.privacyManager).to(showUp())
//            self.app.personalisation.tap()
//            self.app.saveAndExitButton.tap()
//            expect(self.app.privacyManager).to(disappear())
//        }
        
        it("Dismiss message") {
            expect(self.app.consentMessage).to(showUp())
            self.app.dismissButton.tap()
            expect(self.app.consentMessage).to(disappear())
            self.app.relaunch()
            expect(self.app.consentMessage).to(showUp())
        }
        
//      Ignore : currently privacy polisy page returning access denied error
//        it("Privacy Policy link opens in default safari browser") {
//            expect(self.app.consentMessage).to(showUp())
//            self.app.privacyPolicyLink.tap()
//            expect(self.app.privacyPolicyPageTitle).to(showUp())
//        }
    }
}
