//
//  DTNavigationBarController.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

public class DTNavigationController: UINavigationController {
    
    override public func viewDidLoad() {
        
        let bar:UINavigationBar! =  self.navigationBar
 
        bar.shadowImage = UIImage()
        bar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        bar.tintColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor.blackColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}