//
//  ConsentSubViewController.swift
//  SourcePointMetaApp
//
//  Created by Vilas on 5/8/19.
//  Copyright © 2019 Cybage. All rights reserved.
//

import UIKit
import CCPAConsentViewController

class ConsentSubViewController: UIViewController {
    
    var consentSubViewController : CCPAConsentViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _consentSubViewController = consentSubViewController {
            self.view.addSubview(_consentSubViewController.view)
            _consentSubViewController.view.frame = (self.view.bounds)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
