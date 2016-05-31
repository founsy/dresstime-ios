//
//  LoadingView.swift
//  DressTime
//
//  Created by Fab on 5/28/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit


protocol LaunchingViewDelegate {
    func launchingView(view: LaunchingView, startAnimationFinish: Bool)
}

class LaunchingView: UIView {

    @IBOutlet weak var heightCst: NSLayoutConstraint!
    @IBOutlet weak var widthCst: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    
    var delegate: LaunchingViewDelegate?
    
    var mask: CAShapeLayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        let window = UIApplication.sharedApplication().keyWindow!
        let maskImage = UIImage(named: "Icon")!
        self.mask = CAShapeLayer()
        self.mask!.contents = maskImage.CGImage
        self.mask!.contentsScale = maskImage.scale
        self.mask!.contentsGravity = kCAGravityResizeAspect
        self.mask!.fillColor = UIColor.whiteColor().CGColor
        self.mask!.bounds = CGRect(x: 0, y: 0, width: 115, height: 123)
        self.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.mask!.position = CGPoint(x: window.center.x, y: window.center.y)
        self.mask!.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(self.mask!)
    }
    
    func animateMask() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(CGRect: mask!.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.mask!.addAnimation(keyFrameAnimation, forKey: "bounds")
    }
    
    func closeAnimatedView(){
        
        UIView.animateWithDuration(0.2, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.icon.hidden = true
            self.frame = CGRect(origin: CGPoint(x: self.center.x, y: self.center.y) ,size: CGSizeZero)
            }) { (fisish) in
                self.removeFromSuperview()

        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.mask?.removeFromSuperlayer()
        self.removeFromSuperview()        
    }
}