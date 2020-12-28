//
//  Bundle+Framework.swift
//  CCPAConsentViewController
//
//  Created by Vilas on 15/12/20.
//

import class Foundation.Bundle

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var framework: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: CCPAConsentViewController.self)
        #endif
    }()
}
