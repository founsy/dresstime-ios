//
//  RegisterStyleViewControlle.swift
//  DressTime
//
//  Created by Fab on 22/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterStyleViewController: UIViewController {

    @IBOutlet weak var containerRelax: UIImageView!
    @IBOutlet weak var containerAtWork: UIImageView!
    @IBOutlet weak var containerOnParty: UIImageView!
    
    @IBOutlet weak var sportwearStyle: UIImageView!
    @IBOutlet weak var partyStyle: UIImageView!
    @IBOutlet weak var businessStyle: UIImageView!
    @IBOutlet weak var casualStyle: UIImageView!
    
    @IBOutlet weak var styleContainer: UIStackView!
    
    private var lastLocation: CGPoint!
    private var isMoving = false
    
    private var tempUIImage: UIImageView?
    private var relaxImage: UIImageView?
    private var atWorkImage: UIImageView?
    private var onPartyImage: UIImageView?
    
    private var imageSelected: UIImageView?
    private var positionAnimation: CABasicAnimation?
    private var shakeAnimation: CABasicAnimation?
    
    private var currentStyleSeleted: String?
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //lastLocation = homeIcon.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createTempImageView(imageToClone: UIImageView) -> UIImageView {
        let temp = UIImageView(frame: imageToClone.frame)
        temp.image = imageToClone.image
        temp.accessibilityIdentifier = imageToClone.accessibilityIdentifier
        return temp
        
    }
    
    private func whichStyleSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearStyle.convertPoint(location, fromView: self.view)
        if sportwearStyle.pointInside(viewPoint, withEvent: nil) {
            return sportwearStyle
        }
        viewPoint = partyStyle.convertPoint(location, fromView: self.view)
        if partyStyle.pointInside(viewPoint, withEvent: nil) {
            return partyStyle
        }
        viewPoint = businessStyle.convertPoint(location, fromView: self.view)
        if businessStyle.pointInside(viewPoint, withEvent: nil) {
            return businessStyle
        }
        viewPoint = casualStyle.convertPoint(location, fromView: self.view)
        if casualStyle.pointInside(viewPoint, withEvent: nil) {
            return casualStyle
        }
        return nil
    }
    
    private func whichStyle(image: UIImageView) -> CGPoint? {
        if (image.accessibilityIdentifier == "sportwear"){
            return sportwearStyle.convertPoint(sportwearStyle.center, toView: self.view)
        } else if (image.accessibilityIdentifier == "fashion"){
            return partyStyle.convertPoint(partyStyle.center, toView: self.view)
        } else if (image.accessibilityIdentifier == "business"){
            return businessStyle.convertPoint(businessStyle.center, toView: self.view)
        } else if (image.accessibilityIdentifier == "casual"){
            return casualStyle.convertPoint(casualStyle.center, toView: self.view)
        }
        return nil
    }
    
    private func whichContainerSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = containerRelax.convertPoint(location, fromView: self.view)
        if containerRelax.pointInside(viewPoint, withEvent: nil){
            self.relaxImage = self.tempUIImage
            return containerRelax
        }
        viewPoint = containerAtWork.convertPoint(location, fromView: self.view)
        if containerAtWork.pointInside(viewPoint, withEvent: nil){
            self.atWorkImage = self.tempUIImage
            return containerAtWork
        }
        viewPoint = containerOnParty.convertPoint(location, fromView: self.view)
        if containerOnParty.pointInside(viewPoint, withEvent: nil){
            self.onPartyImage = self.tempUIImage
            return containerOnParty
        }
        return nil
    }
    
    private func whichSelectedStyle(location: CGPoint) -> UIImageView?{
        if let image = relaxImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                return image
            }
        }
        if let image = atWorkImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                return image
            }
        }
        if let image = onPartyImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                return image
            }
        }
        return nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Remember original location
        if let tempImage = self.tempUIImage {
            tempImage.layer.removeAllAnimations()
        }
        
       let touch = touches.first
            let location = touch!.locationInView(self.view)
            
            if let icon = self.whichStyleSelected(location) {
                self.imageSelected = icon
                self.tempUIImage = self.createTempImageView(icon)
                self.view.addSubview(self.tempUIImage!)
                isMoving = true
                NSLog("Start to move")
            }
            
            //Inside a container?
            if let tempImage = self.whichSelectedStyle(location) {
                let viewPoint = tempImage.convertPoint(location, fromView: self.view)
                if tempImage.pointInside(viewPoint, withEvent: nil) {
                    self.tempUIImage = tempImage
                    isMoving = true
                    NSLog("Start to move temp")
                }
            }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (isMoving){
            let touch = touches.first
                let location = touch!.locationInView(self.view)
                self.tempUIImage!.center = CGPointMake(location.x, location.y)
            
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let location = touch!.locationInView(touch!.window)
            
            if let container = self.whichContainerSelected(location) {
                NSLog("Animation go to Area")
                animationEnd(container.center)
            } else {
                let viewPoint = whichStyle(self.tempUIImage!)
                NSLog("Animation go back to park area")
                self.view.layoutIfNeeded()
                if let point = viewPoint {
                    animationPark(CGPointMake(point.x - 15.0, point.y - 5.0))
                }
            }
            isMoving = false
    }
    
    private func animationEnd(destination: CGPoint){
        UIView.animateWithDuration(0.5, animations: {
            self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                self.tempUIImage!.center = destination
        })


       /* CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.tempUIImage!.center = destination
        })
        
        self.positionAnimation = CABasicAnimation()
        self.positionAnimation!.keyPath = "position"
        self.positionAnimation!.fillMode = kCAFillModeForwards
        //animation.additive = true
        self.positionAnimation!.removedOnCompletion = false
        self.positionAnimation!.fromValue = NSValue(CGPoint:self.tempUIImage!.center)
        self.positionAnimation!.toValue = NSValue(CGPoint:destination)
        self.positionAnimation!.duration = 0.3
        self.positionAnimation!.beginTime = 0.0
        self.positionAnimation!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.shakeAnimation = CABasicAnimation()
        self.shakeAnimation!.keyPath = "position"
        let point1 = CGPointMake(destination.x - 5, destination.y)
        let point2 = CGPointMake(destination.x + 5, destination.y)
        self.shakeAnimation!.fromValue = NSValue(CGPoint:point1)
        self.shakeAnimation!.toValue = NSValue(CGPoint:point2)
        self.shakeAnimation!.autoreverses = true
        self.shakeAnimation!.repeatCount = 5
        self.shakeAnimation!.duration = 0.1
        self.shakeAnimation!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.shakeAnimation!.beginTime = 0.3
        
        let scaleAnimation = CABasicAnimation()
        scaleAnimation.keyPath = "transform.scale"
        //scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 0.5
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.5
        scaleAnimation.beginTime = 0.3
        self.shakeAnimation!.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.removedOnCompletion = false
        //group.fillMode = kCAFillModeForwards
        group.animations = [self.positionAnimation!, self.shakeAnimation!, scaleAnimation]
        group.duration = 0.8
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        group.beginTime = CACurrentMediaTime()
        
        self.tempUIImage!.layer.addAnimation(group, forKey: nil)
        
        CATransaction.commit() */
    }
    
    func animationPark(destination: CGPoint){
        
        UIView.animateWithDuration(1.0, animations: {
                self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                self.tempUIImage!.removeFromSuperview()
        })

    }

    
}