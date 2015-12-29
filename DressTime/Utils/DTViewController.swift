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

public class DTViewController: UIViewController {
    
    var classNameAnalytics = "UIDTViewController"
    var hideTabBar = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if (hideTabBar){
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let dimensions = [
            "page" : self.classNameAnalytics,    // What type of news is this?
        ]
        PFAnalytics.trackEvent("page", dimensions: dimensions)

        Mixpanel.sharedInstance().track(
             self.classNameAnalytics
        )
        
        self.tabBarController?.tabBar.tintColor = UIColor.dressTimeOrange()
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (hideTabBar){
            self.tabBarController?.tabBar.hidden = false
        }
    }

}