//
//  MessageViewControllerSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 26/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

// swiftlint:disable force_try function_body_length

import Quick
import Nimble
@testable import CCPAConsentViewController

class MessageViewControllerSpec: QuickSpec {

    override func spec() {
        let messageViewController = MessageViewController()

        describe("Test MessageUIDelegate methods") {

            context("Test loadMessage delegate method") {
                it("Test MessageViewController calls loadMessage delegate method") {
                    let WRAPPER_API = URL(string: "https://wrapper-api.sp-prod.net")!
                    messageViewController.loadMessage(fromUrl: WRAPPER_API)
                    expect(messageViewController).notTo(beNil(), description: "loadMessage delegate method calls successfully")
                }
            }
            context("Test loadPrivacyManager delegate method") {
                it("Test MessageViewController calls loadPrivacyManager delegate method") {
                    messageViewController.loadPrivacyManager()
                    expect(messageViewController).notTo(beNil(), description: "loadPrivacyManager delegate method calls successfully")
                }
            }
        }
    }
}
