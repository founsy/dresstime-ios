//
//  DTNavigationBarController.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

open class DTNavigationController: UINavigationController {
    
    override open func viewDidLoad() {
        
        let bar:UINavigationBar! =  self.navigationBar
 
        bar.shadowImage = UIImage()
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.tintColor = UIColor.white
        self.view.backgroundColor = UIColor.black
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}
