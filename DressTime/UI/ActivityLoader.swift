//
//  ActivityLoader.swift
//  DressTime
//
//  Created by Fab on 28/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

open class ActivityLoader: NSObject {
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator: UIActivityLoader!
    
    class var shared: ActivityLoader {
        struct Static {
            static let instance: ActivityLoader = ActivityLoader()
        }
        return Static.instance
    }
    
    override init(){
        super.init()
        activityIndicator = Bundle.main.loadNibNamed("UIActivityLoader", owner: self, options: nil)?[0] as! UIActivityLoader
    }
    
    func showProgressView(_ view: UIView) {
        
        containerView.frame = view.frame
        containerView.center = view.center
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        activityIndicator.center = view.center
        activityIndicator.clipsToBounds = true
        activityIndicator.layer.cornerRadius = 10
        
        containerView.addSubview(activityIndicator)
        view.addSubview(containerView)
        view.bringSubview(toFront: containerView)
        activityIndicator.progessIndicator.startAnimating()
    }
    
    func setLabel(_ value: String){
        activityIndicator.infoLabel.text = value
    }
    
    func hideProgressView() {
        activityIndicator.progessIndicator.startAnimating()
        activityIndicator.infoLabel.text = "Loading..."
        containerView.removeFromSuperview()
    }
}
