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
        self.tabBar.tintColor = UIColor.dressTimeOrange()
        self.selectedViewController = self.viewControllers![1]
    }
}