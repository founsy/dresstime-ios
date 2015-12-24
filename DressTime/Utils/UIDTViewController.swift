//
//  UIDTViewController.swift
//  DressTime
//
//  Created by Fab on 23/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import Parse

public class UIDTViewController: UIViewController {
    
    var classNameAnalytics = "UIDTViewController"
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let dimensions = [
            "page" : self.classNameAnalytics,    // What type of news is this?
        ]
        PFAnalytics.trackEvent("page", dimensions: dimensions)

        Mixpanel.sharedInstance().track(
             self.classNameAnalytics
        )
        

    }

}