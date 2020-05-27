//
//  SimpleClientSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 28/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import CCPAConsentViewController

class ConnectivityMock: Connectivity {
    let isConnected: Bool
    init(connected: Bool) {
        isConnected = connected
    }
    func isConnectedToNetwork() -> Bool {
        return isConnected
    }
}

class SimpleClientSpec: QuickSpec {
    let exampleRequest = URLRequest(url: URL(string: "https://wrapper-api.sp-prod.net")!)

    override func spec() {

        describe("when the result data from the call is different than nil") {
            it("calls the completionHandler with it") {
                var mockedResponse = "{\"url\": \"https://notice.sp-prod.net/?message_id=59706\"}".data(using: .utf8)
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true)
                )
                client.request(self.exampleRequest) { data, _ in mockedResponse = data }
                expect(mockedResponse).toEventuallyNot(beNil())
            }
        }

        describe("when the result data from the call is nil") {
            it("calls the completionHandler with the error") {
                var error: CCPAConsentViewControllerError? = .none
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true))
                client.request(self.exampleRequest) { _, e in error = e }
                expect(error).toEventually(beNil())
            }
        }

        describe("when there's no internet connection") {
            it("calls the completionHandler with an NoInternetConnection error") {
                var error: CCPAConsentViewControllerError?
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: false))
                client.request(self.exampleRequest) { _, e in error = e! }
                expect(error).toEventually(beAKindOf(NoInternetConnection.self))
            }
        }
    }
}
