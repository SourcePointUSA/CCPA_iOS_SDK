//
//  ExampleApp.swift
//  SPCCPAExampleAppUITests
//
//  Created by Vrushali Deshpande on 28/09/20.
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

protocol GDPRUI {
    var consentUI: XCUIElement { get }
    var privacyManager: XCUIElement { get }
    var consentMessage: XCUIElement { get }
}

class ExampleApp: XCUIApplication {
     var privacySettingsButton: XCUIElement {
           buttons["Privacy Settings"].firstMatch
       }
}

extension ExampleApp: GDPRUI {
    var consentUI: XCUIElement {
        webViews.containing(NSPredicate(format: "(label CONTAINS[cd] 'Cookie Notice') OR (label CONTAINS[cd] 'CCPA - Privacy Manager')")).firstMatch
    }

    var privacyManager: XCUIElement {
        webViews.containing(NSPredicate(format: "label CONTAINS[cd] 'Privacy Manager'")).firstMatch
    }

    var consentMessage: XCUIElement {
        webViews.containing(NSPredicate(format: "label CONTAINS[cd] 'Cookie Notice'")).firstMatch
    }

    var acceptAllButton: XCUIElement {
        consentUI.buttons.containing(NSPredicate(format: "label CONTAINS[cd] 'Accept All'")).firstMatch
    }

    var rejectAllButton: XCUIElement {
        consentUI.buttons.containing(NSPredicate(format: "label CONTAINS[cd] 'Reject All'")).firstMatch
    }

    var settings: XCUIElement {
        consentUI.buttons["Settings"].firstMatch
    }

    var saveAndExitButton: XCUIElement {
        privacyManager.buttons["Save & Exit"].firstMatch
    }

    var rejectAll: XCUIElement {
        staticTexts["Reject All"].firstMatch
       }
    
    var dismissButton: XCUIElement {
        staticTexts["X"].firstMatch
    }

    var privacyPolicyLink: XCUIElement {
        consentUI.links["message-link"].firstMatch
    }

    var privacyPolicy: XCUIElement {
        consentUI.links["message-link"].firstMatch
    }

    var personalisation: XCUIElement {
        privacyManager.switches["Personalisation"]
    }
    
    var privacyPolicyPageTitle: XCUIElement {
        webViews.containing(NSPredicate(format: "label CONTAINS[cd] 'Address'")).firstMatch

 //       staticTexts["AccessDenied"].firstMatch
 //       webViews.request.URL.absoluteString
    }
}
