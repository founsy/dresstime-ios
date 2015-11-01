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
    
    private var confirmationView: ConfirmSave?
    
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
                
                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                self.view.bringSubviewToFront(self.confirmationView!)
                UIView.animateAndChainWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: {
                    self.confirmationView?.alpha = 1
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                    }, completion:  nil).animateWithDuration(0.2, animations: { () -> Void in
                        self.confirmationView?.alpha = 0
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                        }, completion: { (finish) -> Void in
                            
                    })
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (currentUserId != nil){
            onValidateButton.setTitle("VALIDATE MY MODIFICATION", forState: UIControlState.Normal)
            labelText.text = "PICK YOUR OWN STYLE"
        } else {
            onValidateButton.titleLabel?.text = "LET'S SEE MY NEW DRESSING"
            onValidateButton.setTitle("LET'S SEE MY NEW DRESSING", forState: UIControlState.Normal)
        }
        
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50, 100, 160)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = currentUserId {
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
            self.tempUIImage = createTempImageView(self.sportwearStyle, location: nil, isInit: true)
        } else if (selectedStyle == "business"){
            self.tempUIImage = createTempImageView(self.businessStyle, location: nil, isInit: true)
        } else if (selectedStyle == "fashion"){
            self.tempUIImage = createTempImageView(self.partyStyle, location: nil, isInit: true)
        } else if (selectedStyle == "casual"){
            self.tempUIImage = createTempImageView(self.casualStyle, location: nil, isInit: true)
        }
        
        let points = container!.superview!.convertRect(container!.frame, toView: nil)
        let center = CGPointMake(CGRectGetMidX(points) + right, CGRectGetMidY(points) - 30)

        self.tempUIImage!.center = center
        self.view.addSubview(self.tempUIImage!)
        //animationEnd(center)
    }
    
    
    private func createTempImageView(imageToClone: UIImageView, location: CGPoint?, isInit: Bool = false) -> UIImageView {
        let temp = UIImageView(frame: imageToClone.frame)
        if let loc = location {
            temp.center = loc
        }
        
        if (isInit){
            temp.image = UIImage(named: getImageNameSelected(imageToClone.accessibilityIdentifier!))
        } else {
            temp.image = imageToClone.image
        }
        temp.accessibilityIdentifier = imageToClone.accessibilityIdentifier
        return temp
        
    }

    private func getImageNameSelected(style: String) -> String{
        var name = ""
        if (style == "sportwear"){
            name = "IconSportwearStyleSelected"
        } else if (style == "fashion"){
            name = "IconFashionStyleSelected"
        } else if (style == "business"){
            name = "IconBusinessStyleSelected"
        } else if (style == "casual"){
            name = "IconCasualStyleSelected"
        }
        return name

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
        if (isMoving){
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
    }
    

    private func animationEnd(destination: CGPoint){
        
        UIView.animateWithDuration(0.5, animations: {
            self.tempUIImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                self.tempUIImage!.center = destination
                self.tempUIImage!.image = UIImage(named: self.getImageNameSelected(self.tempUIImage!.accessibilityIdentifier!))
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