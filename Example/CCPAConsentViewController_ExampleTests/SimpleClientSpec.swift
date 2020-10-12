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

// swiftlint:disable function_body_length

class ConnectivityMock: Connectivity {
    let isConnected: Bool
    init(connected: Bool) {
        isConnected = connected
    }
    func isConnectedToNetwork() -> Bool {
        return isConnected
    }
}

class URLSessionDataTaskMock: CCPAURLSessionDataTask {
    var resumeWasCalled = false

    func resume() {
        resumeWasCalled = true
    }
}

class URLSessionMock: CCPAURLSession {
    let configuration: URLSessionConfiguration
    let dataTaskResult: CCPAURLSessionDataTask
    let result: Data?
    let error: Error?
    var dataTaskCalledWith: URLRequest?

    func dataTask(_ request: URLRequest, completionHandler: @escaping DataTaskResult) -> CCPAURLSessionDataTask {
        dataTaskCalledWith = request
        completionHandler(result, URLResponse(), error)
        return dataTaskResult
    }

    init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        dataTaskResult: CCPAURLSessionDataTask = URLSessionDataTaskMock(),
        data: Data? = nil,
        error: Error? =  nil
    ) {
        self.configuration = configuration
        self.error = error
        self.dataTaskResult = dataTaskResult
        result = data
    }
}

class DispatchQueueMock: CCPADispatchQueue {
    var asyncCalled: Bool?

    func async(execute work: @escaping () -> Void) {
        asyncCalled = true
        work()
    }
}

class SimpleClientSpec: QuickSpec {
    let exampleRequest = URLRequest(url: URL(string: "https://wrapper-api.sp-prod.net")!)

    override func spec() {

        describe("request") {
            it("calls dataTask on its urlSession passing the urlRequest as param") {
                let session = URLSessionMock()
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true),
                    logger: Logger(),
                    urlSession: session,
                    dispatchQueue: DispatchQueue.main
                )
                client.request(self.exampleRequest) { _, _ in }
                expect(session.dataTaskCalledWith).to(equal(self.exampleRequest))
            }

            it("calls async on its dispatchQueue with the result of the dataTask") {
                let queue = DispatchQueueMock()
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true),
                    logger: Logger(),
                    urlSession: URLSession.shared,
                    dispatchQueue: queue
                )
                client.request(self.exampleRequest) { _, _ in }
                expect(queue.asyncCalled).toEventually(beTrue())
            }

            it("calls resume on the result of the dataTask") {
                let dataTaskResult = URLSessionDataTaskMock()
                let session = URLSessionMock(
                    configuration: URLSessionConfiguration.default,
                    dataTaskResult: dataTaskResult
                )
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true),
                    logger: Logger(),
                    urlSession: session,
                    dispatchQueue: DispatchQueue.main
                )
                client.request(self.exampleRequest) { _, _ in }
                expect(dataTaskResult.resumeWasCalled).to(beTrue())
            }
        }

        describe("when the result data from the call is different than nil") {
            it("calls the completionHandler with it") {
                var result: Data?
                let session = URLSessionMock(
                    configuration: URLSessionConfiguration.default,
                    data: "".data(using: .utf8),
                    error: nil
                )
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true),
                    logger: Logger(),
                    urlSession: session,
                    dispatchQueue: DispatchQueueMock()
                )
                client.request(self.exampleRequest) { data, _ in result = data }
                expect(result).toEventuallyNot(beNil())
            }
        }

        describe("when the result data from the call is nil") {
            it("calls the completionHandler with the error") {
                var error: CCPAConsentViewControllerError?
                let session = URLSessionMock(
                    configuration: URLSessionConfiguration.default,
                    data: nil,
                    error: CCPAGeneralRequestError(nil, nil, nil)
                )
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: true),
                    logger: Logger(),
                    urlSession: session,
                    dispatchQueue: DispatchQueueMock()
                )
                client.request(self.exampleRequest) { _, e in error = e }
                expect(error).toEventuallyNot(beNil())
            }
        }

        describe("when there's no internet connection") {
            it("calls the completionHandler with an NoInternetConnection error") {
                var error: CCPAConsentViewControllerError?
                let client = SimpleClient(
                    connectivityManager: ConnectivityMock(connected: false),
                    logger: Logger(),
                    urlSession: URLSession.shared,
                    dispatchQueue: DispatchQueue.main
                )
                client.request(self.exampleRequest) { _, e in error = e! }
                expect(error).toEventually(beAKindOf(CCPANoInternetConnection.self))
            }
        }
    }
}
