//
//  ActivityLoader.swift
//  DressTime
//
//  Created by Fab on 28/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

public class ActivityLoader {
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: ActivityLoader {
        struct Static {
            static let instance: ActivityLoader = ActivityLoader()
        }
        return Static.instance
    }
    
    func showProgressView(view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        
        progressView.frame = CGRectMake(0, 0, 150, 100)
        progressView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        progressView.center = view.center
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 100, 100)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        view.bringSubviewToFront(containerView)
        
        activityIndicator.startAnimating()
    }
    
    func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}