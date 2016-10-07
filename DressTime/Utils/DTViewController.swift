//
//  UIDTViewController.swift
//  DressTime
//
//  Created by Fab on 23/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

open class DTViewController: UIViewController {
    
    var classNameAnalytics = "UIDTViewController"
    var hideTabBar = false
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if (hideTabBar){
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        OneSignal.defaultClient().sendTag("page", value: self.classNameAnalytics)
        
        Mixpanel.sharedInstance().track(
             self.classNameAnalytics
        )
        
        //self.tabBarController?.tabBar.tintColor = UIColor.dressTimeOrange()
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (hideTabBar){
            self.tabBarController?.tabBar.isHidden = false
        }
    }

}
