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
        self.tabBar.tintColor = UIColor.dressTimeRedBrand()
        
        for item in self.tabBar.items! {
            if item.tag == 1 {
                item.title =  NSLocalizedString("tabBarItemWardrobe", comment: "")
            } else if item.tag == 2 {
                item.title =  NSLocalizedString("tabBarItemCalendar", comment: "")
            } else if item.tag == 3 {
                item.title =  NSLocalizedString("tabBarItemDaily", comment: "")
            } else if item.tag == 4 {
                item.title =  NSLocalizedString("tabBarItemShopping", comment: "")
            }
        }
        self.selectedViewController = self.viewControllers![0]
    }
}