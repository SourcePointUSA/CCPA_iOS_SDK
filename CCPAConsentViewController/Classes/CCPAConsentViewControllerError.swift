//
//  ConsentError.swift
//  CCPAConsentViewController
//
//  Created by Andre Herculano on 12.03.19.
//

import Foundation

@objcMembers public class CCPAConsentViewControllerError: NSError, LocalizedError {
    init() {
        super.init(domain: "CCPAConsentViewController", code: 0, userInfo: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers public class CCPAGeneralRequestError: CCPAConsentViewControllerError {
    public let url, response, error: String

    public var failureReason: String? { return "The request to: \(url) failed with response: \(response) and error: \(error)" }
    public var errorDescription: String? { return "Error while requesting from: \(url)" }

    init(_ url: URL?, _ response: URLResponse?, _ error: Error?) {
        self.url = url?.absoluteString ?? "<Unknown Url>"
        self.response = response?.description ?? "<Unknown Response>"
        self.error = error?.localizedDescription ?? "<Unknown Error>"
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public var description: String { return "\(failureReason!)" }
}

@objcMembers public class CCPAAPIParsingError: CCPAConsentViewControllerError {
    private let parsingError: Error?
    private let endpoint: String

    init(_ endpoint: String, _ error: Error?) {
        self.endpoint = endpoint
        self.parsingError = error
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override public var description: String { return "Error parsing response from \(endpoint): \(parsingError.debugDescription)" }
    public var errorDescription: String? { return description }
    public var failureReason: String? { return description }
}

@objcMembers public class CCPAUnableToLoadJSReceiver: CCPAConsentViewControllerError {
    public var failureReason: String? { return "Unable to load the JSReceiver.js resource." }
    override public var description: String { return "\(failureReason!)\n" }
}

@objcMembers public class CCPANoInternetConnection: CCPAConsentViewControllerError {
    public var failureReason: String? { return "The device is not connected to the internet." }
    override public var description: String { return "\(failureReason!)\n" }
}

@objcMembers public class CCPAMessageEventParsingError: CCPAConsentViewControllerError {
    let message: String

    init(message: String) {
        self.message = message
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var failureReason: String? { return "Could not parse message coming from the WebView \(message)" }
    override public var description: String { return "\(failureReason!)\n" }
}

@objcMembers public class CCPAWebViewError: CCPAConsentViewControllerError {
    public var failureReason: String? { return "Something went wrong in the webview" }
    override public var description: String { return "\(failureReason!)\n" }
}

@objcMembers public class CCPAURLParsingError: CCPAConsentViewControllerError {
    let urlString: String

    init(urlString: String) {
        self.urlString = urlString
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var failureReason: String? { return "Could not parse URL: \(urlString)" }
    override public var description: String { return "\(failureReason!)\n" }
}

@objcMembers public class CCPAInvalidArgumentError: CCPAConsentViewControllerError {
    let message: String

    init(message: String) {
        self.message = message
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var failureReason: String? { return message }
    override public var description: String { return message }
}
