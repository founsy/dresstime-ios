//
//  DTTabBarController.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit


public class DTTabBarController: UITabBarController {

    override public func viewDidLoad() {
        self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.backgroundColor = UIColor.dressTimeOrange()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        
        self.selectedViewController = self.viewControllers![2]
    }
}