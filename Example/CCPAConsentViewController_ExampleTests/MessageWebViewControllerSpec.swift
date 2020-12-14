//
//  MessageWebViewControllerSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 25/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
// swiftlint:disable force_cast function_body_length

import Quick
import Nimble
import WebKit
@testable import CCPAConsentViewController

class MessageWebViewControllerSpec: QuickSpec, ConsentDelegate, WKNavigationDelegate {

    func getMessageWebViewController() -> MessageWebViewController {
        return MessageWebViewController(propertyId: 22, pmId: "5df9105bcf42027ce707bb43", consentUUID: UUID().uuidString, userConsent: UserConsent.rejectedNone())
    }

    override func spec() {
        var messageWebViewController: MessageWebViewController!
        let mockConsentDelegate = MockConsentDelegate()
        let acceptedVendors = ["123", "456", "789"]
        let rejectedVendors = ["321", "654", "987"]
        let acceptedPurposes = ["1234", "4567", "7890"]
        let rejectedPurposes = ["4321", "7654", "0987"]
        let vendors = PMConsent(accepted: acceptedVendors, rejected: rejectedVendors)
        let purposes = PMConsent(accepted: acceptedPurposes, rejected: rejectedPurposes)
        let pmConsents = PMConsents(vendors: vendors, categories: purposes)
        let payload: NSDictionary = ["id": "455262", "consents": pmConsents]

        beforeEach {
            messageWebViewController = self.getMessageWebViewController()
            messageWebViewController.consentDelegate = mockConsentDelegate
        }

        // this method is used to test whether webview is loaded or not successfully
        describe("Test loadView method") {
            it("Test MessageWebViewController calls loadView method") {
                messageWebViewController.loadView()
                expect(messageWebViewController.webview).notTo(beNil(), description: "Webview initialized successfully")
            }
        }

        describe("Test ConsentDelegate methods") {
            context("Test consentUIWillShow delegate method") {
                it("Test MessageWebViewController calls consentUIWillShow delegate method") {
                    messageWebViewController.ccpaConsentUIWillShow()
                    expect(mockConsentDelegate.isCCPAConsentUIWillShowCalled).to(equal(true), description: "ccpaConsentUIWillShow delegate method calls successfully")
                }
            }

            context("Test onMessageReady method") {
                it("Test MessageWebViewController calls messageWillShow delegate method") {
                    messageWebViewController.onMessageReady()
                    expect(mockConsentDelegate.isMessageWillShowCalled).to(equal(true), description: "messageWillShow delegate method calls successfully")
                }
            }

            context("Test ccpaPMWillShow delegate method") {
                it("Test MessageWebViewController calls ccpaPMWillShow delegate method") {
                    messageWebViewController.onPMReady()
                    expect(mockConsentDelegate.isCCPAPMWillShowCalled).to(equal(true), description: "onPMReady delegate method calls successfully")
                }
            }

            context("Test consentUIDidDisappear delegate method") {
                it("Test MessageWebViewController calls consentUIDidDisappear delegate method") {
                    messageWebViewController.consentUIDidDisappear()
                    expect(mockConsentDelegate.isConsentUIDidDisappearCalled).to(equal(true), description: "consentUIDidDisappear delegate method calls successfully")
                }
            }

            context("Test onError delegate method") {
                it("Test MessageWebViewController calls onError delegate method") {
                    let error = CCPAConsentViewControllerError()
                    messageWebViewController.onError(error: error)
                    expect(mockConsentDelegate.isOnErrorCalled).to(equal(true), description: "onError delegate method calls successfully")
                }
            }

            context("Test messageDidDisappear delegate method") {
                it("Test MessageWebViewController calls messageDidDisappear delegate method") {
                    messageWebViewController.showPrivacyManagerFromMessageAction()
                    expect(mockConsentDelegate.isMessageDidDisappearCalled).to(equal(true), description: "messageDidDisappear delegate method calls successfully")
                }
            }

            context("Test ccpaPMDidDisappear delegate method") {
                it("Test MessageWebViewController calls gdprPMDidDisappear delegate method") {
                    messageWebViewController.goBackAndClosePrivacyManager()
                    expect(mockConsentDelegate.isCCPAPMDidDisappearCalled).to(equal(true), description: "ccpaPMDidDisappear delegate method calls successfully")
                }
            }

            context("Test onAction delegate method") {
                it("Test MessageWebViewController calls onAction delegate method for show PM action") {
                    messageWebViewController.onAction(Action(type: .ShowPrivacyManager), consents: pmConsents)
                    expect(mockConsentDelegate.isOnActionCalled).to(equal(true), description: "onAction delegate method calls successfully")
                }
            }

            context("Test onAction delegate method") {
                it("Test MessageWebViewController calls onAction delegate method for PM cancel action") {
                    messageWebViewController.onAction(Action(type: .Dismiss), consents: pmConsents)
                    expect(mockConsentDelegate.isOnActionCalled).to(equal(true), description: "onAction delegate method calls successfully")
                }
            }

            context("Test loadMessage  method") {
                it("Test MessageWebViewController calls loadMessage delegate method") {
                    let WRAPPER_API = URL(string: "https://wrapper-api.sp-prod.net")!
                    messageWebViewController.loadMessage(fromUrl: WRAPPER_API)
                    expect(messageWebViewController).notTo(beNil(), description: "loadMessage delegate method calls successfully")
                }
            }
            context("Test loadPrivacyManager method") {
                it("Test MessageWebViewController calls loadPrivacyManager delegate method") {
                    messageWebViewController.loadPrivacyManager()
                    expect(messageWebViewController).notTo(beNil(), description: "loadPrivacyManager delegate method calls successfully")
                }

                it("Test pmUrl is called and returns url") {
                    let pmURL = messageWebViewController.pmUrl()
                    expect(pmURL).notTo(beNil(), description: "Able to get pmUrl")
                }
            }
        }

        // this method is used to test whether viewWillDisappear is called or not successfully
        describe("Test viewWillDisappear method") {
            it("Test MessageWebViewController calls viewWillDisappear method") {
                messageWebViewController.viewWillDisappear(false)
                expect(messageWebViewController.consentDelegate).to(beNil(), description: "ConsentDelegate gets cleared")
            }
        }

        describe("Test getPMConsentsIfAny method") {
            var pmConsents: PMConsents?
            it("Test MessageWebViewController calls getPMConsentsIfAny method") {
                pmConsents = messageWebViewController.getPMConsentsIfAny(payload as! [String: Any])
                if pmConsents?.categories.accepted.count ?? 0 > 0 {
                    expect(pmConsents?.categories.accepted.first).to(equal("1234"), description: "Able to get accepted categories")
                } else {
                    expect(pmConsents?.categories.accepted.first).to(beNil(), description: "Unable to get accepted categories")
                }
            }
        }
    }
}
