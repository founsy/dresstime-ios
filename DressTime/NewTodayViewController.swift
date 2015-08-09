//
//  NewTodayViewController.swift
//  DressTime
//
//  Created by Fab on 08/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class NewTodayViewController: UIViewController {
   
    var isFullScreen: Bool = false
    var lastFrame: CGRect?
    
    @IBOutlet weak var filterView: UIView!

    @IBAction func onShowFilter(sender: AnyObject) {
        
        UIView.animateWithDuration(0.7, delay: 0.0, options: .CurveEaseOut, animations: {
                if (!self.isFullScreen){
                    var frame = self.filterView.frame
                    self.lastFrame = frame
            
                    frame.size.height = UIScreen.mainScreen().bounds.height - frame.origin.y
                    self.filterView.frame = frame
                } else {
                    self.filterView.frame = self.lastFrame!
                    
                }
            }, completion: { finished in
                println("Basket doors opened!")
                self.isFullScreen = !self.isFullScreen
        })
        
    }

}