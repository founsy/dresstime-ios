//
//  UIDTViewController.swift
//  DressTime
//
//  Created by Fab on 23/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

public class DTViewController: UIViewController {
    
    var classNameAnalytics = "UIDTViewController"
    var hideTabBar = false
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if (hideTabBar){
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        OneSignal.defaultClient().sendTag("page", value: self.classNameAnalytics)
        
        Mixpanel.sharedInstance().track(
             self.classNameAnalytics
        )
        
        //self.tabBarController?.tabBar.tintColor = UIColor.dressTimeOrange()
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (hideTabBar){
            self.tabBarController?.tabBar.hidden = false
        }
    }

}