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
    func launchingView(_ view: LaunchingView, startAnimationFinish: Bool)
}

class LaunchingView: UIView , CAAnimationDelegate {

    @IBOutlet weak var heightCst: NSLayoutConstraint!
    @IBOutlet weak var widthCst: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    
    var delegate: LaunchingViewDelegate?
    
    var maskLayer: CAShapeLayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        let window = UIApplication.shared.keyWindow!
        let maskImage = UIImage(named: "Icon")!
        self.maskLayer = CAShapeLayer()
        self.maskLayer!.contents = maskImage.cgImage
        self.maskLayer!.contentsScale = maskImage.scale
        self.maskLayer!.contentsGravity = kCAGravityResizeAspect
        self.maskLayer!.fillColor = UIColor.white.cgColor
        self.maskLayer!.bounds = CGRect(x: 0, y: 0, width: 115, height: 123)
        self.maskLayer!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.maskLayer!.position = CGPoint(x: window.center.x, y: window.center.y)
        self.maskLayer!.backgroundColor = UIColor.clear.cgColor
        self.layer.addSublayer(self.maskLayer!)
    }
    
    func animateMask() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(cgRect: maskLayer!.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.maskLayer!.add(keyFrameAnimation, forKey: "bounds")
    }
    
    func closeAnimatedView(){
        
        UIView.animate(withDuration: 0.2, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.icon.isHidden = true
            self.frame = CGRect(origin: CGPoint(x: self.center.x, y: self.center.y) ,size: CGSize.zero)
            }) { (fisish) in
                self.removeFromSuperview()

        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.maskLayer?.removeFromSuperlayer()
        self.removeFromSuperview()        
    }
}
