//
//  SourcePointClientSpec.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Vilas on 26/05/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
// swiftlint:disable force_try function_body_length

import Quick
import Nimble
@testable import CCPAConsentViewController

public class MockHttp: HttpClient {
    var getWasCalledWithUrl: URL?
    var postWasCalledWithUrl: URL?
    var postWasCalledWithBody: Data?
    var success: Data?
    var error: Error?

    init(success: Data?) {
        self.success = success
    }

    init(error: Error?) {
        self.error = error
    }

    public func get(url: URL?, completionHandler: @escaping CompletionHandler) {
        getWasCalledWithUrl = url?.absoluteURL
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.success != nil ?
                completionHandler(self.success!, nil) :
                completionHandler(nil, CCPAAPIParsingError(url!.absoluteString, self.error))
        })
    }

    func request(_ urlRequest: URLRequest, _ completionHandler: @escaping CompletionHandler) {}

    public func post(url: URL?, body: Data?, completionHandler: @escaping CompletionHandler) {
        postWasCalledWithUrl = url?.absoluteURL
        postWasCalledWithBody = body
        var urlRequest = URLRequest(url: postWasCalledWithUrl!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.success != nil ?
                completionHandler(self.success!, nil) :
                completionHandler(nil, CCPAAPIParsingError(url!.absoluteString, self.error))
        })
    }
}

class SourcePointClientSpec: QuickSpec {
    let propertyId = 6099
    let consentUUID = "sp_ccpa_consentUUID"
    let propertyName = try! PropertyName("ccpa.mobile.demo")

    func getClient(_ client: MockHttp) -> SourcePointClient {
        return SourcePointClient(
            accountId: 22,
            propertyId: propertyId,
            propertyName: propertyName,
            pmId: "5df9105bcf42027ce707bb43",
            campaignEnv: .Public,
            targetingParams: ["native": "false"],
            client: client)
    }

    override func spec() {
        Nimble.AsyncDefaults.Timeout = 2
        var client: SourcePointClient!
        var httpClient: MockHttp?
        var mockedResponse: Data?
        var pmConsents: PMConsents!
        let acceptAllAction = Action.AcceptAll

        describe("Test SourcePointClient Methods") {
            beforeEach {
                mockedResponse = "{\"url\": \"https://notice.sp-prod.net/?message_id=59706\"}".data(using: .utf8)
                httpClient = MockHttp(success: mockedResponse)
                client = self.getClient(httpClient!)
            }

            context("Test targetingParamsToString") {
                it("Test TargetingParamsToString with parameter") {
                    let targetingParams = ["native": "false"]
                    let targetingParamString = client.targetingParamsToString(targetingParams)
                    let encodeTargetingParam = "{\"native\":\"false\"}".data(using: .utf8)
                    let encodedString = String(data: encodeTargetingParam!, encoding: .utf8)
                    expect(targetingParamString).to(equal(encodedString))
                }
            }

            context("Test getMessage") {
                it("get the right url to load the message") {
                    let messageURL = client.getMessageUrl(self.consentUUID, propertyName: self.propertyName, authId: "TestMessageUrl")
                    expect(messageURL!.scheme).to(equal("https"))
                    expect(messageURL!.host).to(equal("wrapper-api.sp-prod.net"))
                    expect(messageURL?.path).to(equal("/ccpa/message-url"))
                }

                it("calls get on the http client with the right url") {
                    client.getMessage(consentUUID: self.consentUUID, authId: "TestMessageUrl", completionHandler: { _, _ in })
                    expect(httpClient?.getWasCalledWithUrl?.scheme).to(equal("https"))
                    expect(httpClient?.getWasCalledWithUrl?.host).to(equal("wrapper-api.sp-prod.net"))
                    expect(httpClient?.getWasCalledWithUrl?.path).to(equal("/ccpa/message-url"))
                }

                context("on success") {
                    it("calls the completion handler with a getMessage") {
                        var messageResponse: MessageResponse?
                        client.getMessage(consentUUID: self.consentUUID, authId: "TestMessageUrl") { response, _ in
                            messageResponse = response
                        }
                        expect(messageResponse).toEventually(beNil())
                    }

                    it("calls completion handler with nil as error") {
                        var error: CCPAConsentViewControllerError? = .none
                        client.getMessage(consentUUID: self.consentUUID, authId: "TestMessageUrl") { _, e in
                            error = e
                        }
                        expect(error).toEventually(beNil())
                    }
                }

                context("on failure") {
                    beforeEach {
                        client = self.getClient(MockHttp(error: nil))
                    }

                    it("calls the completion handler with an CCPAConsentViewControllerError") {
                        var error: CCPAConsentViewControllerError?
                        client.getMessage(consentUUID: self.consentUUID, authId: "TestMessageUrl") { _, e in
                            error = e
                        }
                        expect(error).toEventually(beAKindOf(CCPAConsentViewControllerError.self))
                    }
                }
            }
            describe("postAction") {
                context("Test postAction") {
                    beforeEach {
                        let acceptedVendors = ["123", "456", "789"]
                        let rejectedVendors = ["321", "654", "987"]
                        let acceptedPurposes = ["1234", "4567", "7890"]
                        let rejectedPurposes = ["4321", "7654", "0987"]
                        let vendors = PMConsent(accepted: acceptedVendors, rejected: rejectedVendors)
                        let purposes = PMConsent(accepted: acceptedPurposes, rejected: rejectedPurposes)
                        pmConsents = PMConsents(vendors: vendors, categories: purposes)
                    }

                    it("get the right post url") {
                        let postActionURL = client.postActionUrl(Action.AcceptAll.rawValue)
                        expect(postActionURL?.absoluteString).to(equal("https://wrapper-api.sp-prod.net/ccpa/consent/11"))
                    }

                    it("calls post on the http client with the right url") {
                        client.postAction(action: acceptAllAction, consentUUID: self.consentUUID, consents: pmConsents, completionHandler: { _, _  in})
                        expect(httpClient?.postWasCalledWithUrl).to(equal(URL(string: "https://wrapper-api.sp-prod.net/ccpa/consent/11")))
                    }
                }

                context("on success") {
                    it("calls the completion handler with a postAction") {
                        var actionResponse: ActionResponse?
                        client.postAction(action: acceptAllAction, consentUUID: self.consentUUID, consents: pmConsents) { response, _ in
                            actionResponse = response
                        }
                        expect(actionResponse).toEventually(beNil())
                    }

                    it("calls completion handler with nil as error") {
                        var error: CCPAConsentViewControllerError? = .none
                        client.postAction(action: acceptAllAction, consentUUID: self.consentUUID, consents: pmConsents) { _, e in
                            error = e
                        }
                        expect(error).toEventually(beNil())
                    }
                }

                context("on failure") {
                    beforeEach {
                        client = self.getClient(MockHttp(error: nil))
                    }

                    it("calls the completion handler with an CCPAConsentViewControllerError") {
                        var error: CCPAConsentViewControllerError?
                        client.postAction(action: acceptAllAction, consentUUID: self.consentUUID, consents: pmConsents) { _, e in
                            error = e
                        }
                        expect(error).toEventually(beAKindOf(CCPAConsentViewControllerError.self))
                    }
                }
            }
        }
    }
}
