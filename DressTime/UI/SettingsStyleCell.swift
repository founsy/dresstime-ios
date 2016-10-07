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
    
    fileprivate var isMoving = false
    
    fileprivate var tempUIImage: UIImageView?
    fileprivate var relaxImage: UIImageView?
    fileprivate var atWorkImage: UIImageView?
    fileprivate var onPartyImage: UIImageView?
    
    fileprivate var relaxSelected: String?
    fileprivate var atWorkSelected: String?
    fileprivate var onPartySelected: String?
    
    fileprivate var imageSelected: UIImageView?
    fileprivate var currentStyleSelected: String?
    
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tableView = self.superview?.superview as? UITableView {
            tableView.isScrollEnabled = false
        }
        if (!self.isMoving){
            
            // Remember original location
            if let tempImage = self.tempUIImage {
                tempImage.layer.removeAllAnimations()
            }
            
            let touch = touches.first
            let location = touch!.location(in: self)
            
            if let icon = self.whichStyleSelected(location) {
                NSLog("Frame of selected icon \(icon.frame.origin.x) \(icon.frame.origin.y)")
                self.imageSelected = icon
                self.tempUIImage = self.createTempImageView(icon, location: location)
                self.addSubview(self.tempUIImage!)
                isMoving = true
                NSLog("Start to move")
            } else if let tempImage = self.whichSelectedStyle(location) {  //Inside a container?
                let viewPoint = tempImage.convert(location, from: self)
                if tempImage.point(inside: viewPoint, with: nil) {
                    self.tempUIImage = tempImage
                    isMoving = true
                    NSLog("Start to move temp")
                }
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isMoving){
            let touch = touches.first
            let location = touch!.location(in: self)
            self.tempUIImage!.center = CGPoint(x: location.x, y: location.y)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch!.location(in: touch!.window)
        
        if let container = self.whichContainerSelected(location) {
            let points = self.containerView.convert(container.frame, to: self)
            let center = CGPoint(x: points.midX, y: points.midY)
            animationEnd(center)
        } else {
            let viewPoint = whichStyle(self.tempUIImage!)
            if let point = viewPoint {
                NSLog("Animation go back to park area")
                animationPark(CGPoint(x: point.x - 15.0, y: point.y - 5.0))
            } else {
                NSLog("Remove uiImageView")
                self.tempUIImage!.removeFromSuperview()
            }
        }
        if let tableView = self.superview?.superview as? UITableView {
            tableView.isScrollEnabled = true
        }
        self.currentStyleSelected = nil
        
    }
    
    fileprivate func animationEnd(_ destination: CGPoint){
        
        UIView.animate(withDuration: 0.5, animations: {
            self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                self.tempUIImage!.center = destination
                self.isMoving = false
        })
    }
    
    fileprivate func animationPark(_ destination: CGPoint){
        
        UIView.animate(withDuration: 0.5, animations: {
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
    
    fileprivate func initStyleSelected(_ selectedStyle: String, containerName: String) {
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

    
    fileprivate func whichStyleSelected(_ location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearStyle.convert(location, from: self)
        if sportwearStyle.point(inside: viewPoint, with: nil) {
            self.currentStyleSelected = "sportwear"
            return sportwearStyle
        }
        viewPoint = fashionStyle.convert(location, from: self)
        if fashionStyle.point(inside: viewPoint, with: nil) {
            self.currentStyleSelected = "fashion"
            return fashionStyle
        }
        viewPoint = businessStyle.convert(location, from: self)
        if businessStyle.point(inside: viewPoint, with: nil) {
            self.currentStyleSelected = "business"
            return businessStyle
        }
        viewPoint = casualChicStyle.convert(location, from: self)
        if casualChicStyle.point(inside: viewPoint, with: nil) {
            self.currentStyleSelected = "casual"
            return casualChicStyle
        }
        return nil
    }
    
    fileprivate func whichContainerSelected(_ location: CGPoint) -> UIImageView? {
        var viewPoint = relaxContainer.convert(location, from: self)
        if relaxContainer.point(inside: viewPoint, with: nil){
            self.relaxImage = self.tempUIImage
            self.relaxSelected = self.currentStyleSelected
            return relaxContainer
        }
        viewPoint = atWorkContainer.convert(location, from: self)
        if atWorkContainer.point(inside: viewPoint, with: nil){
            self.atWorkImage = self.tempUIImage
            self.atWorkSelected = self.currentStyleSelected
            return atWorkContainer
        }
        viewPoint = onPartyContainer.convert(location, from: self)
        if onPartyContainer.point(inside: viewPoint, with: nil){
            self.onPartyImage = self.tempUIImage
            self.onPartySelected = self.currentStyleSelected
            return onPartyContainer
        }
        return nil
    }
    
    fileprivate func whichSelectedStyle(_ location: CGPoint) -> UIImageView?{
        if let image = relaxImage {
            let viewPoint = image.convert(location, from: self)
            if image.point(inside: viewPoint, with: nil){
                self.relaxSelected = nil
                return image
            }
        }
        if let image = atWorkImage {
            let viewPoint = image.convert(location, from: self)
            if image.point(inside: viewPoint, with: nil){
                self.atWorkSelected = nil
                return image
            }
        }
        if let image = onPartyImage {
            let viewPoint = image.convert(location, from: self)
            if image.point(inside: viewPoint, with: nil){
                self.onPartySelected = nil
                return image
            }
        }
        return nil
    }
    
    
    fileprivate func whichStyle(_ image: UIImageView) -> CGPoint? {
        if (image.accessibilityIdentifier == "sportwear"){
            return sportwearStyle.convert(sportwearStyle.center, to: self)
        } else if (image.accessibilityIdentifier == "fashion"){
            return fashionStyle.convert(fashionStyle.center, to: self)
        } else if (image.accessibilityIdentifier == "business"){
            return businessStyle.convert(businessStyle.center, to: self)
        } else if (image.accessibilityIdentifier == "casual"){
            return casualChicStyle.convert(casualChicStyle.center, to: self)
        }
        return nil
    }
    
    fileprivate func createTempImageView(_ imageToClone: UIImageView, location: CGPoint?) -> UIImageView {
        let temp = UIImageView(frame: imageToClone.frame)
        if let loc = location {
            temp.center = loc
        }
        temp.image = imageToClone.image
        temp.accessibilityIdentifier = imageToClone.accessibilityIdentifier
        return temp
        
    }


}
