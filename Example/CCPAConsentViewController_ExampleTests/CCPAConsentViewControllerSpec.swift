//
//  CCPAConsentViewControllerSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 24/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
// swiftlint:disable force_try function_body_length

import Quick
import Nimble
@testable import CCPAConsentViewController

public class MockConsentDelegate: ConsentDelegate {
    var isConsentUIWillShowCalled = false
    var isCCPAConsentUIWillShowCalled = false
    var isConsentUIDidDisappearCalled = false
    var isOnErrorCalled = false
    var isOnActionCalled = false
    var isOnConsentReadyCalled = false
    var isMessageWillShowCalled = false
    var isMessageDidDisappearCalled = false
    var isCCPAPMWillShowCalled = false
    var isCCPAPMDidDisappearCalled = false

    public func consentUIWillShow() {
        isConsentUIWillShowCalled = true
    }

    public func ccpaConsentUIWillShow() {
        isCCPAConsentUIWillShowCalled = true
    }

    public func consentUIDidDisappear() {
        isConsentUIDidDisappearCalled = true
    }

    public func onError(error: CCPAConsentViewControllerError?) {
        isOnErrorCalled = true
    }

    public func onAction(_ action: Action, consents: PMConsents?) {
        isOnActionCalled = true
    }

    public func onConsentReady(consentUUID: ConsentUUID, userConsent: UserConsent) {
        isOnConsentReadyCalled = true
    }

    public func messageWillShow() {
        isMessageWillShowCalled = true
    }

    public func messageDidDisappear() {
        isMessageDidDisappearCalled = true
    }

    public func ccpaPMWillShow() {
        isCCPAPMWillShowCalled = true
    }

    public func ccpaPMDidDisappear() {
        isCCPAPMDidDisappearCalled = true
    }

}

class CCPAConsentViewControllerSpec: QuickSpec, ConsentDelegate {

    func getCCPAConsentViewController() -> CCPAConsentViewController {
        return CCPAConsentViewController(
            accountId: 22,
            propertyId: 6099,
            propertyName: try! PropertyName("ccpa.mobile.demo"),
            PMId: "5df9105bcf42027ce707bb43",
            campaignEnv: .Public,
            consentDelegate: self)
    }

    override func spec() {
        var consentViewController = self.getCCPAConsentViewController()
        let mockConsentDelegate = MockConsentDelegate()
        let consentUUID = UUID().uuidString
        let messageViewController = MessageViewController()
        let rejectedVendors = ["321", "654", "987"]
        let rejectedCategories = ["4321", "7654", "0987"]
        let userConsents = UserConsent(
            status: .RejectedSome,
            rejectedVendors: rejectedVendors,
            rejectedCategories: rejectedCategories
        )

        describe("load Message in webview") {
            beforeEach {
                consentViewController = self.getCCPAConsentViewController()
            }

            it("Load message in webview without authId") {
                consentViewController.loadMessage()
                expect(consentViewController.loading).to(equal(.Loading), description: "loadMessage method works as expected")
            }

            it("Load message in webview with authId") {
                consentViewController.loadMessage(forAuthId: "SPTestMessage")
                expect(consentViewController.loading).to(equal(.Loading), description: "loadMessage method with authID works as expected")
            }
        }

        describe("load Privacy Manager") {
            beforeEach {
                consentViewController = self.getCCPAConsentViewController()
            }

            it("Load privacy manager in webview") {
                consentViewController.loadPrivacyManager()
                expect(consentViewController.loading).to(equal(.Loading), description: "loadPrivacyManager method works as expected")
            }
        }

        describe("get stored user consents and consent UUID") {
            beforeEach {
                UserDefaults.standard.set("sp_ccpa_consentUUID", forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
                consentViewController = self.getCCPAConsentViewController()
            }

            it("get stored user consents") {
                let userConsents = CCPAConsentViewController.getStoredUserConsents()
                expect(userConsents.status.rawValue).to(equal("rejectedNone"), description: "userConsents is stored in UserDefaults")
            }

            it("get stored consentUUID") {
                let consentUUID = CCPAConsentViewController.getStoredConsentUUID()
                expect(consentUUID).to(equal("sp_ccpa_consentUUID"), description: "consentUUID is stored in UserDefaults")
            }
        }

        describe("Get right value for authID change status") {
            beforeEach {
                consentViewController = self.getCCPAConsentViewController()
            }

            it("Test did AuthId Change") {
                let authIdChangeStatus = consentViewController.didAuthIdChange(newAuthId: Date().description)
                expect(authIdChangeStatus).to(equal(true), description: "Auth Id changed successfully")
            }
        }

        describe("Clears UserDefaults ") {
            beforeEach {
                UserDefaults.standard.set("sp_ccpa_meta", forKey: CCPAConsentViewController.META_KEY)
                UserDefaults.standard.set("sp_ccpa_consentUUID", forKey: CCPAConsentViewController.CONSENT_UUID_KEY)
                consentViewController = self.getCCPAConsentViewController()
            }

            it("Clears all data from the UserDefaults") {
                consentViewController.clearAllConsentData()
                let consentUUID = UserDefaults.standard.dictionaryRepresentation().filter {
                    $0.key.starts(with: CCPAConsentViewController.CONSENT_UUID_KEY)
                }
                expect(consentUUID).to(beEmpty())
            }

            it("Clears all consent data from the UserDefaults") {
                consentViewController.clearAllConsentData()
                let metaKey = UserDefaults.standard.string(forKey: CCPAConsentViewController.META_KEY)
                expect(metaKey).to(beNil(), description: "Upon successful call to clearAllConsentData META_KEY gets cleared")
            }
        }

        describe("Test ConsentDelegate methods") {
            beforeEach {
                consentViewController = self.getCCPAConsentViewController()
                consentViewController.consentDelegate = mockConsentDelegate
            }
            context("Test consentUIWillShow delegate method") {
                it("Test CCPAConsentViewController calls consentUIWillShow delegate method") {
                    consentViewController.ccpaConsentUIWillShow()
                    if consentViewController.messageViewController == nil {
                        expect(consentViewController.messageViewController).to(beNil())
                    } else {
                        expect(mockConsentDelegate.isConsentUIWillShowCalled).to(equal(true), description: "consentUIWillShow delegate method calls successfully")
                    }
                }
            }

            context("Test consentUIDidDisappear delegate method") {
                it("Test CCPAConsentViewController calls consentUIDidDisappear delegate method") {
                    consentViewController.consentUIDidDisappear()
                    expect(mockConsentDelegate.isConsentUIDidDisappearCalled).to(equal(true), description: "consentUIDidDisappear delegate method calls successfully")
                }
            }

            context("Test onError delegate method") {
                it("Test CCPAConsentViewController calls onError delegate method") {
                    let error = CCPAConsentViewControllerError()
                    consentViewController.onError(error: error)
                    expect(mockConsentDelegate.isOnErrorCalled).to(equal(true), description: "onError delegate method calls successfully")
                }
            }

            context("onConsentReady delegate method") {

                it("calls onConsentReady delegate method") {
                    consentViewController.onConsentReady(consentUUID: consentUUID, userConsent: userConsents)
                    expect(mockConsentDelegate.isOnConsentReadyCalled).to(equal(true), description: "onConsentReady delegate method calls successfully")
                }

                it("should set the consentUUID in the UserDefaults") {
                    consentViewController.onConsentReady(consentUUID: "sp_ccpa_consentUUID", userConsent: userConsents)
                    expect(UserDefaults.standard.string(forKey: CCPAConsentViewController.CONSENT_UUID_KEY)).to(equal("sp_ccpa_consentUUID"))
                }

                it("should set the consentUUID as attribute of CCPAConsentViewController") {
                    consentViewController.onConsentReady(consentUUID: "sp_ccpa_consentUUID", userConsent: userConsents)
                    expect(consentViewController.consentUUID).to(equal("sp_ccpa_consentUUID"))
                }
            }

            context("Test messageWillShow delegate method") {
                it("Test CCPAConsentViewController calls messageWillShow delegate method") {
                    consentViewController.messageWillShow()
                    expect(mockConsentDelegate.isMessageWillShowCalled).to(equal(true), description: "messageWillShow delegate method calls successfully")
                }
            }

            context("Test messageDidDisappear delegate method") {
                it("Test CCPAConsentViewController calls messageDidDisappear delegate method") {
                    consentViewController.messageDidDisappear()
                    expect(mockConsentDelegate.isMessageDidDisappearCalled).to(equal(true), description: "messageDidDisappear delegate method calls successfully")
                }
            }

            context("Test consentUIDidDisappear delegate method") {
                it("Test CCPAConsentViewController calls consentUIDidDisappear delegate method") {
                    consentViewController.consentUIDidDisappear()
                    expect(mockConsentDelegate.isConsentUIDidDisappearCalled).to(equal(true), description: "consentUIDidDisappear delegate method calls successfully")
                }
            }

            context("Test ccpaPMWillShow delegate method") {
                it("Test CCPAConsentViewController calls ccpaPMWillShow delegate method") {
                    consentViewController.ccpaPMWillShow()
                    expect(mockConsentDelegate.isCCPAPMWillShowCalled).to(equal(true), description: "ccpaPMWillShow delegate method calls successfully")
                }
            }

            context("Test ccpaPMDidDisappear delegate method") {
                it("Test CCPAConsentViewController calls ccpaPMDidDisappear delegate method") {
                    consentViewController.ccpaPMDidDisappear()
                    expect(mockConsentDelegate.isCCPAPMDidDisappearCalled).to(equal(true), description: "ccpaPMDidDisappear delegate method calls successfully")
                }
            }
        }

        describe("Test Add/Remove MessageViewController") {
            beforeEach {
                consentViewController = self.getCCPAConsentViewController()
            }

            it("Test add MessageViewController into viewcontroller stack") {
                let viewController = UIViewController()
                consentViewController.add(asChildViewController: viewController)
                let navigationController = UINavigationController(rootViewController: consentViewController)
                let controllersInStack = navigationController.viewControllers
                if let messageViewController = controllersInStack.first(where: { $0 is MessageViewController }) {
                    expect(messageViewController).to(equal(MessageViewController.self()), description: "MessageViewController is added into naviagtion stack")
                } else {
                    expect(consentViewController.messageViewController).to(beNil(), description: "MessageViewController is not added into naviagtion stack")
                }
            }

            it("Test remove MessageViewController from viewcontroller stack") {
                consentViewController.add(asChildViewController: messageViewController)
                consentViewController.remove(asChildViewController: messageViewController)
                expect(consentViewController.messageViewController).to(beNil(), description: "MessageViewController is removed from naviagtion stack")
            }
        }
    }
}
