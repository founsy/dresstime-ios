//
//  LoadingViewController.swift
//  DressTime
//
//  Created by Fab on 5/25/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var widthImage: NSLayoutConstraint!
    @IBOutlet weak var heightImage: NSLayoutConstraint!
    @IBOutlet weak var imageViewLogo: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
         NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoadingViewController.dismissController(_:)), name: "OutfitLoaded", object: nil)
        
            }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
       /* widthImage.constant = 86
        heightImage.constant = 86
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.imageViewLogo.layoutIfNeeded()
            }, completion: nil)
        */

    }
    
    func dismissController(notification: NSNotification) {
        print("Dismiss")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromTop
        
        navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
        self.dismissViewControllerAnimated(false, completion: nil)
       // self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}