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
    @IBOutlet weak var containerView: UIView!
    
    private var lastLocation: CGPoint!
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
    
    var currentUserId: String?

    @IBOutlet weak var onValidateButton: UIButton!
    @IBOutlet weak var labelText: UILabel!
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        if let userId = currentUserId {
            let dal = ProfilsDAL()
            if let profil = dal.fetch(userId) {
                profil.atWorkStyle = self.atWorkSelected
                profil.onPartyStyle = self.onPartySelected
                profil.relaxStyle = self.relaxSelected
                dal.update(profil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //lastLocation = homeIcon.center
        if (currentUserId != nil){
            onValidateButton.setTitle("VALIDATE MY MODIFICATION", forState: UIControlState.Normal)
            labelText.text = "PICK YOUR OWN STYLE"
        } else {
            onValidateButton.titleLabel?.text = "LET'S SEE MY NEW DRESSING"
            onValidateButton.setTitle("LET'S SEE MY NEW DRESSING", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = currentUserId {
            self.view.setNeedsUpdateConstraints()
            self.view.updateConstraintsIfNeeded()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            initData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initData(){
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(self.currentUserId!) {
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
    
    private func initStyleSelected(selectedStyle: String, containerName: String) {
        var container: UIImageView?
        var right:CGFloat = 0.0
        //var iconStyle: UIImageView?
        if (containerName == "relax") {
            container = self.containerRelax
        } else if (containerName == "onParty") {
            container = self.containerOnParty
            right = -8.5
        } else if (containerName == "atWork") {
            container = self.containerAtWork
            right = 8.5
        }
        
        if (selectedStyle == "sportwear"){
            self.tempUIImage = createTempImageView(self.sportwearStyle, location: nil)
        } else if (selectedStyle == "business"){
            self.tempUIImage = createTempImageView(self.businessStyle, location: nil)
        } else if (selectedStyle == "fashion"){
            self.tempUIImage = createTempImageView(self.partyStyle, location: nil)
        } else if (selectedStyle == "casual"){
            self.tempUIImage = createTempImageView(self.casualStyle, location: nil)
        }
        
        let points = container!.superview!.convertRect(container!.frame, toView: nil)
        let center = CGPointMake(CGRectGetMidX(points) + right, CGRectGetMidY(points) - 22.5)

        self.tempUIImage!.center = center
        self.view.addSubview(self.tempUIImage!)
        //animationEnd(center)
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

    
    private func whichStyleSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearStyle.convertPoint(location, fromView: self.view)
        if sportwearStyle.pointInside(viewPoint, withEvent: nil) {
             self.currentStyleSelected = "sportwear"
            return sportwearStyle
        }
        viewPoint = partyStyle.convertPoint(location, fromView: self.view)
        if partyStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "fashion"
            return partyStyle
        }
        viewPoint = businessStyle.convertPoint(location, fromView: self.view)
        if businessStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "business"
            return businessStyle
        }
        viewPoint = casualStyle.convertPoint(location, fromView: self.view)
        if casualStyle.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "casual"
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
            self.relaxSelected = self.tempUIImage?.accessibilityIdentifier
            return containerRelax
        }
        viewPoint = containerAtWork.convertPoint(location, fromView: self.view)
        if containerAtWork.pointInside(viewPoint, withEvent: nil){
            self.atWorkImage = self.tempUIImage
            self.atWorkSelected = self.tempUIImage?.accessibilityIdentifier
            return containerAtWork
        }
        viewPoint = containerOnParty.convertPoint(location, fromView: self.view)
        if containerOnParty.pointInside(viewPoint, withEvent: nil){
            self.onPartyImage = self.tempUIImage
            self.onPartySelected = self.tempUIImage?.accessibilityIdentifier
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
         if (!self.isMoving){
            // Remember original location
            if let tempImage = self.tempUIImage {
                tempImage.layer.removeAllAnimations()
            }
        
            let touch = touches.first
            let location = touch!.locationInView(self.view)
            
            if let icon = self.whichStyleSelected(location) {
                self.imageSelected = icon
                self.tempUIImage = self.createTempImageView(icon, location: location)
                self.view.addSubview(self.tempUIImage!)
                isMoving = true
                NSLog("Start to move")
            } else if let tempImage = self.whichSelectedStyle(location) {
                let viewPoint = tempImage.convertPoint(location, fromView: self.view) //Inside a container?
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
                if let point = viewPoint {
                    NSLog("Animation go back to park area")
                    animationPark(CGPointMake(point.x - 15.0, point.y - 5.0))
                } else {
                    NSLog("Remove uiImageView")
                    self.tempUIImage!.removeFromSuperview()
                }
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

    
}