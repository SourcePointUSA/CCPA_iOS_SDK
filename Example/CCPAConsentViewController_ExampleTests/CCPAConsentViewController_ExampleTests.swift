//
//  SourcePointClient.swift
//  CCPAConsentViewController_ExampleTests
//
//  Created by Andre Herculano on 25.11.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Quick
import Nimble
@testable import CCPAConsentViewController

public class MockHttp: HttpClient {
    public var defaultOnError: OnError?
    var getCalledWith: URL?
    var success: Data?
    var error: Error?
    
    init(success: Data?) {
        self.success = success
    }
    
    init(error: Error?) {
        self.error = error
    }
    
    public func get(url: URL?, onSuccess: @escaping OnSuccess) {
        getCalledWith = url?.absoluteURL
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            onSuccess(self.success!)
        })
    }
    
    public func post(url: URL?, body: Data?, onSuccess: @escaping OnSuccess) {
        getCalledWith = url?.absoluteURL
        var urlRequest = URLRequest(url: getCalledWith!)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            onSuccess(self.success!)
        })
    }
}

class SourcePointClientSpec: QuickSpec {
    func getClient(_ client: MockHttp) -> SourcePointClient {
        return SourcePointClient(accountId: 123, propertyId: 123, propertyName: try! PropertyName("ccpa.mobile.demo"), pmId: "5df9105bcf42027ce707bb43", campaignEnv: .Public, targetingParams: [:], client: client)
    }
    
    override func spec() {
        var client: SourcePointClient!
        var httpClient: MockHttp?
        var mockedResponse: Data?
        
        describe("getMessageUrl") {
            describe("with a valid MessageResponse") {
                beforeEach {
                    mockedResponse = "{\"url\": \"https://notice.sp-prod.net/?message_id=59706\"}".data(using: .utf8)
                    httpClient = MockHttp(success: mockedResponse)
                    client = self.getClient(httpClient!)
                }
                
                xit("calls get on the http client with the right url") {
                    _ = client.getMessageUrl("744BC49E-7327-4255-9794-FB07AA43E1DF", propertyName: try! PropertyName("ccpa.mobile.demo"))
                    expect(httpClient?.getCalledWith).to(equal(URL(string: "https://fake_wrapper_api.com/getMessageUrl")))
                }
                
                xit("returns the url of a message") {
                    client.getMessage(consentUUID: "744BC49E-7327-4255-9794-FB07AA43E1DF", onSuccess: { _ in})
                    expect(httpClient?.getCalledWith).to(equal(URL(string: "https://fake_wrapper_api.com/getMessageUrl")))
                }
            }
        }
    }
}
