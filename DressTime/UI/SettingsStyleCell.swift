        //
//  SettingsStyleCell.swift
//  DressTime
//
//  Created by Fab on 06/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class SettingsStyleCell: UITableViewCell {
    @IBOutlet weak var atWorkContainer: UIImageView!
    @IBOutlet weak var onPartyContainer: UIImageView!
    @IBOutlet weak var relaxContainer: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var sportwearStyle: UIImageView!
    @IBOutlet weak var fashionStyle: UIImageView!
    @IBOutlet weak var businessStyle: UIImageView!
    @IBOutlet weak var casualChicStyle: UIImageView!
    
    private var isMoving = false
    
    private var tempUIImage: UIImageView?
    private var relaxImage: UIImageView?
    private var atWorkImage: UIImageView?
    private var onPartyImage: UIImageView?
    
    private var relaxSelected: String?
    private var atWorkSelected: String?
    private var onPartySelected: String?
    
    private var imageSelected: UIImageView?
    private var currentStyleSelected: String?
    
    override func awakeFromNib(){
        super.awakeFromNib()
        self.layoutIfNeeded()

     /*   let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            if let style = user.onPartyStyle {
                initStyleSelected(style, containerName: "onParty")
                self.onPartyImage = self.tempUIImage
                self.onPartySelected = self.tempUIImage?.accessibilityIdentifier
            }
            if let style = user.relaxStyle {
                initStyleSelected(style, containerName: "relax")
                self.relaxImage = self.tempUIImage
                self.relaxSelected = self.tempUIImage?.accessibilityIdentifier
            }
            
            if let style = user.atWorkStyle{
                initStyleSelected(style, containerName: "atWork")
                self.atWorkImage = self.tempUIImage
                self.atWorkSelected = self.tempUIImage?.accessibilityIdentifier
            }
            
        } */
    }
    
    func initData(){
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            if let style = user.onPartyStyle {
                initStyleSelected(style, containerName: "onParty")
                self.onPartyImage = self.tempUIImage
                self.onPartySelected = self.tempUIImage?.accessibilityIdentifier
            }
            if let style = user.relaxStyle {
                initStyleSelected(style, containerName: "relax")
                self.relaxImage = self.tempUIImage
                self.relaxSelected = self.tempUIImage?.accessibilityIdentifier
            }
            
            if let style = user.atWorkStyle{
                initStyleSelected(style, containerName: "atWork")
                self.atWorkImage = self.tempUIImage
                self.atWorkSelected = self.tempUIImage?.accessibilityIdentifier
            }
            
        }

    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let tableView = self.superview?.superview as? UITableView {
            tableView.scrollEnabled = false
        }
        if (!self.isMoving){
            
            // Remember original location
            if let tempImage = self.tempUIImage {
                tempImage.layer.removeAllAnimations()
            }
            
            let touch = touches.first
            let location = touch!.locationInView(self)
            
            if let icon = self.whichStyleSelected(location) {
                NSLog("Frame of selected icon \(icon.frame.origin.x) \(icon.frame.origin.y)")
                self.imageSelected = icon
                self.tempUIImage = self.createTempImageView(icon, location: location)
                self.addSubview(self.tempUIImage!)
                isMoving = true
                NSLog("Start to move")
            } else if let tempImage = self.whichSelectedStyle(location) {  //Inside a container?
                let viewPoint = tempImage.convertPoint(location, fromView: self)
                if tempImage.pointInside(viewPoint, withEvent: nil) {
                    self.tempUIImage = tempImage
                    isMoving = true
                    NSLog("Start to move temp")
                }
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (isMoving){
            let touch = touches.first
            let location = touch!.locationInView(self)
            self.tempUIImage!.center = CGPointMake(location.x, location.y)
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let location = touch!.locationInView(touch!.window)
        
        if let container = self.whichContainerSelected(location) {
            let points = self.containerView.convertRect(container.frame, toView: self)
            let center = CGPointMake(CGRectGetMidX(points), CGRectGetMidY(points))
            animationEnd(center)
        } else {
            let viewPoint = whichStyle(self.tempUIImage!)
            if let point = viewPoint {
                NSLog("Animation go back to park area")
                animationPark(CGPointMake(point.x - 15.0, point.y - 5.0))
            } else {
                NSLog("Remove uiImageView")
                self.tempUIImage!.removeFromSuperview()
            }
        }
        if let tableView = self.superview?.superview as? UITableView {
            tableView.scrollEnabled = true
        }
        self.currentStyleSelected = nil
        
    }
    
    private func animationEnd(destination: CGPoint){
        
        UIView.animateWithDuration(0.5, animations: {
            self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                self.tempUIImage!.center = destination
                self.isMoving = false
        })
    }
    
    private func animationPark(destination: CGPoint){
        
        UIView.animateWithDuration(0.5, animations: {
            self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                if let _ = self.tempUIImage {
                    self.tempUIImage!.removeFromSuperview()
                    self.tempUIImage = nil
                }
                self.isMoving = false
        })
        
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
            self.tempUIImage = createTempImageView(self.sportwearStyle, location: nil)
        } else if (selectedStyle == "business"){
            self.tempUIImage = createTempImageView(self.businessStyle, location: nil)
        } else if (selectedStyle == "fashion"){
            self.tempUIImage = createTempImageView(self.fashionStyle, location: nil)
        } else if (selectedStyle == "casual"){
            self.tempUIImage = createTempImageView(self.casualChicStyle, location: nil)
        }
        
        self.tempUIImage!.center = container!.center
        self.containerView.addSubview(self.tempUIImage!)
        
        
    }

    
    private func whichStyleSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearStyle.convertPoint(location, fromView: self)
        if sportwearStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "sportwear"
            return sportwearStyle
        }
        viewPoint = fashionStyle.convertPoint(location, fromView: self)
        if fashionStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "fashion"
            return fashionStyle
        }
        viewPoint = businessStyle.convertPoint(location, fromView: self)
        if businessStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "business"
            return businessStyle
        }
        viewPoint = casualChicStyle.convertPoint(location, fromView: self)
        if casualChicStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "casual"
            return casualChicStyle
        }
        return nil
    }
    
    private func whichContainerSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = relaxContainer.convertPoint(location, fromView: self)
        if relaxContainer.pointInside(viewPoint, withEvent: nil){
            self.relaxImage = self.tempUIImage
            self.relaxSelected = self.currentStyleSelected
            return relaxContainer
        }
        viewPoint = atWorkContainer.convertPoint(location, fromView: self)
        if atWorkContainer.pointInside(viewPoint, withEvent: nil){
            self.atWorkImage = self.tempUIImage
            self.atWorkSelected = self.currentStyleSelected
            return atWorkContainer
        }
        viewPoint = onPartyContainer.convertPoint(location, fromView: self)
        if onPartyContainer.pointInside(viewPoint, withEvent: nil){
            self.onPartyImage = self.tempUIImage
            self.onPartySelected = self.currentStyleSelected
            return onPartyContainer
        }
        return nil
    }
    
    private func whichSelectedStyle(location: CGPoint) -> UIImageView?{
        if let image = relaxImage {
            let viewPoint = image.convertPoint(location, fromView: self)
            if image.pointInside(viewPoint, withEvent: nil){
                self.relaxSelected = nil
                return image
            }
        }
        if let image = atWorkImage {
            let viewPoint = image.convertPoint(location, fromView: self)
            if image.pointInside(viewPoint, withEvent: nil){
                self.atWorkSelected = nil
                return image
            }
        }
        if let image = onPartyImage {
            let viewPoint = image.convertPoint(location, fromView: self)
            if image.pointInside(viewPoint, withEvent: nil){
                self.onPartySelected = nil
                return image
            }
        }
        return nil
    }
    
    
    private func whichStyle(image: UIImageView) -> CGPoint? {
        if (image.accessibilityIdentifier == "sportwear"){
            return sportwearStyle.convertPoint(sportwearStyle.center, toView: self)
        } else if (image.accessibilityIdentifier == "fashion"){
            return fashionStyle.convertPoint(fashionStyle.center, toView: self)
        } else if (image.accessibilityIdentifier == "business"){
            return businessStyle.convertPoint(businessStyle.center, toView: self)
        } else if (image.accessibilityIdentifier == "casual"){
            return casualChicStyle.convertPoint(casualChicStyle.center, toView: self)
        }
        return nil
    }
    
    private func createTempImageView(imageToClone: UIImageView, location: CGPoint?) -> UIImageView {
        let temp = UIImageView(frame: imageToClone.frame)
        if let loc = location {
            temp.center = loc
        }
        temp.image = imageToClone.image
        temp.accessibilityIdentifier = imageToClone.accessibilityIdentifier
        return temp
        
    }


}