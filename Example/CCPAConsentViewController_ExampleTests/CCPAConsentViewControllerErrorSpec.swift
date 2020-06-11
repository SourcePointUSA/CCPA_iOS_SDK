//
//  CCPAConsentViewControllerErrorSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 24/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import CCPAConsentViewController

class CCPAConsentViewControllerErrorSpec: QuickSpec {

    override func spec() {

        let urlString = "https://notice.sp-prod.net/?message_id=59706"

        describe("Test GDPRConsentViewControllerError methods") {

            it("Test GeneralRequestError method") {
                let url = URL(string: urlString)
                let errorObject = GeneralRequestError(url, nil, nil)
                expect(errorObject.description).to(
                    equal("The request to: \(urlString) failed with response: <Unknown Response> and error: <Unknown Error>"))
            }

            it("Test APIParsingError method") {
                let errorObject = APIParsingError(urlString, nil)
                expect(errorObject.description).to(equal("Error parsing response from \(urlString): nil"))
            }

            it("Test NoInternetConnection method") {
                let errorObject = NoInternetConnection()
                expect(errorObject.failureReason).to(equal("The device is not connected to the internet."))
            }

            it("Test MessageEventParsingError method") {
                let errorObject = MessageEventParsingError(message: "The operation couldn't be completed")
                expect(errorObject.failureReason).to(equal("Could not parse message coming from the WebView The operation couldn't be completed"))
            }

            it("Test WebViewError method") {
                let errorObject = WebViewError()
                expect(errorObject.failureReason).to(equal("Something went wrong in the webview"))
            }

            it("Test URLParsingError method") {
                let errorObject = URLParsingError(urlString: urlString)
                expect(errorObject.failureReason).to(equal("Could not parse URL: \(urlString)"))
            }

            it("Test InvalidArgumentError method") {
                let errorObject = InvalidArgumentError(message: "The operation couldn't be completed")
                expect(errorObject.description).to(equal("The operation couldn't be completed"))
            }
        }
    }
}

