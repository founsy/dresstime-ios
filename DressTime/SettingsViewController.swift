//
//  NewSettingsViewController.swift
//  DressTime
//
//  Created by Fab on 01/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailName: UITextField!
    @IBOutlet weak var temperatureSegmented: UISegmentedControl!
    
    
    @IBOutlet weak var atWorkContainer: UIImageView!
    @IBOutlet weak var onPartyContainer: UIImageView!
    @IBOutlet weak var relaxContainer: UIImageView!
    
    @IBOutlet weak var sportwearStyle: UIImageView!
    @IBOutlet weak var fashionStyle: UIImageView!
    @IBOutlet weak var businessStyle: UIImageView!
    @IBOutlet weak var casualChicStyle: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackStyleView: UIStackView!
    
    private var user: Profil?
    private var tempUIImage: UIImageView?
    private var relaxImage: UIImageView?
    private var atWorkImage: UIImageView?
    private var onPartyImage: UIImageView?
    
    private var relaxSelected: String?
    private var atWorkSelected: String?
    private var onPartySelected: String?
    
    private var imageSelected: UIImageView?
    private var currentStyleSelected: String?
    private var positionAnimation: CABasicAnimation?
    private var shakeAnimation: CABasicAnimation?
    
    private var isMoving = false
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        print(self.relaxSelected)
        print(self.atWorkSelected)
        print(self.onPartySelected)
        if let userSaving = self.user {
         /*   if (gender.selectedSegmentIndex == 0){
                userSaving.gender = "M"
            } else {
                userSaving.gender = "F"
            } */
            
            if (temperatureSegmented.selectedSegmentIndex == 0){
                userSaving.temp_unit = "C"
            } else {
                userSaving.temp_unit = "F"
            }
            if let relax = self.relaxSelected {
                userSaving.relaxStyle = relax
            }
            if let onParty = self.onPartySelected {
                userSaving.onPartyStyle = onParty
            }
            if let atWork = self.atWorkSelected {
                userSaving.atWorkStyle = atWork
            }
            if let email = self.emailName.text {
                userSaving.email = email
            }
            if let name = self.nameText.text {
                userSaving.name = name
            }
            let profilDal = ProfilsDAL()
            profilDal.update(userSaving)
            
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            let jsonObject: [String: AnyObject] = [
                "access_token": user.access_token!
            ]
            
            LoginService.logoutMethod(jsonObject, getCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
                //if (succeeded){
                let dal = ProfilsDAL()
                let profilOld = dal.fetch(user.userid!)
                if let profil = profilOld {
                    profil.access_token = ""
                    profil.refresh_token = ""
                    profil.expire_in = 0
                    dal.update(profil)
                }
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    //Go back to login window
                    let rootController:UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController")
                    self.presentViewController(rootController, animated: true, completion: nil)
                })
                //}
            })
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            nameText.text = user.userid
            
            /*if (user.gender == "M"){
                gender.selectedSegmentIndex = 0
            } else {
                gender.selectedSegmentIndex = 1
            } */
            
            if (user.temp_unit == "C") {
                temperatureSegmented.selectedSegmentIndex = 0
            } else {
                temperatureSegmented.selectedSegmentIndex = 1
            }
            
            if let style = user.onPartyStyle {
                initStyleSelected(style, containerName: "onParty")
            }
            if let style = user.relaxStyle {
                initStyleSelected(style, containerName: "relax")
            }

            if let style = user.atWorkStyle{
                initStyleSelected(style, containerName: "atWork")
            }

        }
        
    }
    
    private func initStyleSelected(selectedStyle: String, containerName: String) {
        var container: UIImageView?
        //var iconStyle: UIImageView?
        if (containerName == "relax") {
            container = self.relaxContainer
        } else if (containerName == "onParty") {
            container = self.onPartyContainer
        } else if (containerName == "atWork") {
            container = self.atWorkContainer
        }
        
        if (selectedStyle == "sportwear"){
            self.tempUIImage = createTempImageView(self.sportwearStyle)
        } else if (selectedStyle == "business"){
            self.tempUIImage = createTempImageView(self.businessStyle)
        } else if (selectedStyle == "fashion"){
            self.tempUIImage = createTempImageView(self.fashionStyle)
        } else if (selectedStyle == "casual"){
            self.tempUIImage = createTempImageView(self.casualChicStyle)
        }
        let points = self.containerView.convertRect(container!.frame, toView: self.view)
        let center = CGPointMake(CGRectGetMidX(points), CGRectGetMidY(points))
        self.tempUIImage!.center = center
        self.view.addSubview(self.tempUIImage!)
        //animationEnd(center)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Remember original location
        if let tempImage = self.tempUIImage {
            tempImage.layer.removeAllAnimations()
        }
        
        let touch = touches.first
        let location = touch!.locationInView(self.view)
        
        if let icon = self.whichStyleSelected(location) {
            NSLog("Frame of selected icon \(icon.frame.origin.x) \(icon.frame.origin.y)")
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
            let points = self.containerView.convertRect(container.frame, toView: self.view)
            let center = CGPointMake(CGRectGetMidX(points), CGRectGetMidY(points))
            animationEnd(center)
        } else {
            NSLog("Animation go back to park area")
            NSLog("Moved Icon \(self.imageSelected!.frame.origin.x) \(self.imageSelected!.frame.origin.y)")
            let points = self.view.convertRect(self.imageSelected!.frame, toView: self.stackStyleView)
            let center = CGPointMake(CGRectGetMidX(points), CGRectGetMidY(points))
            NSLog("Moved Icon \(center.x) \(center.y)")
            animationEnd(center)
        }
         self.currentStyleSelected = nil
        isMoving = false
    }
    
    private func animationEnd(destination: CGPoint){
        CATransaction.begin()
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
        
        CATransaction.commit()
    }

    private func whichStyleSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearStyle.convertPoint(location, fromView: self.view)
        if sportwearStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "sportwear"
            return sportwearStyle
        }
        viewPoint = fashionStyle.convertPoint(location, fromView: self.view)
        if fashionStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "fashion"
            return fashionStyle
        }
        viewPoint = businessStyle.convertPoint(location, fromView: self.view)
        if businessStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "business"
            return businessStyle
        }
        viewPoint = casualChicStyle.convertPoint(location, fromView: self.view)
        if casualChicStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "casual"
            return casualChicStyle
        }
        return nil
    }
    
    private func whichContainerSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = relaxContainer.convertPoint(location, fromView: self.view)
        if relaxContainer.pointInside(viewPoint, withEvent: nil){
            self.relaxImage = self.tempUIImage
            self.relaxSelected = self.currentStyleSelected
            return relaxContainer
        }
        viewPoint = atWorkContainer.convertPoint(location, fromView: self.view)
        if atWorkContainer.pointInside(viewPoint, withEvent: nil){
            self.atWorkImage = self.tempUIImage
            self.atWorkSelected = self.currentStyleSelected
            return atWorkContainer
        }
        viewPoint = onPartyContainer.convertPoint(location, fromView: self.view)
        if onPartyContainer.pointInside(viewPoint, withEvent: nil){
            self.onPartyImage = self.tempUIImage
            self.onPartySelected = self.currentStyleSelected
            return onPartyContainer
        }
        return nil
    }
    
    private func whichSelectedStyle(location: CGPoint) -> UIImageView?{
        if let image = relaxImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                self.relaxSelected = nil
                return image
            }
        }
        if let image = atWorkImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                self.atWorkSelected = nil
                return image
            }
        }
        if let image = onPartyImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                self.onPartySelected = nil
                return image
            }
        }
        return nil
    }
    
    private func createTempImageView(imageToClone: UIImageView) -> UIImageView {
        let temp = UIImageView(frame: imageToClone.frame)
        temp.image = imageToClone.image
        return temp
        
    }
    
}