//
//  NewRegisterStyleViewContainer.swift
//  DressTime
//
//  Created by Fab on 28/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterStyleViewController : UIViewController {

    @IBOutlet weak var areaAtWork: UIImageView!
    @IBOutlet weak var areaOnParty: UIImageView!
    @IBOutlet weak var areaRelax: UIImageView!
    
    @IBOutlet weak var sportwearIcon: UIImageView!
    @IBOutlet weak var fashionIcon: UIImageView!
    @IBOutlet weak var businessIcon: UIImageView!
    @IBOutlet weak var casualIcon: UIImageView!
    
    @IBOutlet weak var onValidateButton: UIButton!
    @IBOutlet weak var labelText: UILabel!
    
    private var isMoving = false
    private var currentStyleSelected = ""
    private var tempImage: UIImageView?
    
    private var relaxImage: UIImageView?
    private var atWorkImage: UIImageView?
    private var onPartyImage: UIImageView?
    
    private var relaxSelected: String?
    private var atWorkSelected: String?
    private var onPartySelected: String?
    
    private var confirmationView: ConfirmSave?
    
    var currentUserId: String?
    
    var email: String?
    var password: String?
    var sexe: String?
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        //Edit Mode
        if (!isValidData()){
            ActivityLoader.shared.hideProgressView()
            let alert = UIAlertController(title: NSLocalizedString("styleErrTitle", comment: ""), message: NSLocalizedString("styleErrMessage", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("styleErrButton", comment: ""), style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            return
        }
        
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
                            self.navigationController?.popViewControllerAnimated(true)
                    })
                
            }
        } else {
            let dal = ProfilsDAL()
            let profil = dal.save(email!, email: email!, access_token: "", refresh_token: "", expire_in: 3600, name: "", gender: sexe!, temp_unit: "C")
            profil.atWorkStyle = self.atWorkSelected
            profil.onPartyStyle = self.onPartySelected
            profil.relaxStyle = self.relaxSelected
            dal.update(profil)
            
            UserService().CreateUser(profil, password: password!, completion: { (isSuccess, object) -> Void in
                if (isSuccess){
                    //Create Model
                    self.loginSuccess(profil, password: self.password!)
                    UIView.animateAndChainWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: {
                        self.confirmationView?.alpha = 1
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                        }, completion:  nil).animateWithDuration(0.2, animations: { () -> Void in
                            self.confirmationView?.alpha = 0
                            self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                            }, completion: { (finish) -> Void in
                                
                        })
                }
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentUserId != nil){
            onValidateButton.setTitle(NSLocalizedString("VALIDATE MY MODIFICATION", comment: ""), forState: UIControlState.Normal)
            labelText.text = NSLocalizedString("PICK YOUR OWN STYLE", comment: "")
        } else {
            onValidateButton.titleLabel?.text = NSLocalizedString("LET'S SEE MY NEW DRESSING", comment: "")
            onValidateButton.setTitle(NSLocalizedString("LET'S SEE MY NEW DRESSING", comment: ""), forState: UIControlState.Normal)
        }
        
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50, 100, 100)
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!self.isMoving){
            let touch = touches.first
            let location = touch!.locationInView(self.view)
            
            if let selectedStyle = whichStyleSelected(location) {
                NSLog("Start to move")
                self.tempImage = createCloneImage(selectedStyle, location: location)
                self.tempImage!.frame.origin = location
                self.view.addSubview(self.tempImage!)
                 isMoving = true
            } else if let tempImage = self.whichMomentSelected(location) {
                let viewPoint = tempImage.convertPoint(location, fromView: self.view) //Inside a container?
                if tempImage.pointInside(viewPoint, withEvent: nil) {
                    self.tempImage = tempImage
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
            if let img = self.tempImage {
                img.center = CGPointMake(location.x, location.y)
            }
           
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (isMoving){
            if let _ = self.tempImage {
                if let container = self.whichContainerSelected() {
                    NSLog("Animation go to Area")
                    if (isAreaEmpty(container)){
                        setStyleForArea(container, style: self.tempImage!.accessibilityIdentifier!)
                        animationEnd(container.center)
                    } else {
                        goBackArea()
                    }
                } else {
                    goBackArea()
                }
            }
        }
    }
    
    private func isValidData() -> Bool {
        return !((relaxSelected == nil || relaxSelected!.isEmpty) ||
            (onPartySelected == nil || onPartySelected!.isEmpty) ||
            (atWorkSelected == nil || atWorkSelected!.isEmpty))
    }
    
    private func initData(){
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(self.currentUserId!) {
            if let style = user.onPartyStyle {
                initStyleSelected(style, containerName: "onParty")
                self.onPartyImage = self.tempImage
                self.onPartySelected = self.tempImage?.accessibilityIdentifier
            }
            if let style = user.relaxStyle {
                initStyleSelected(style, containerName: "relax")
                self.relaxImage = self.tempImage
                self.relaxSelected = self.tempImage?.accessibilityIdentifier
            }
            
            if let style = user.atWorkStyle{
                initStyleSelected(style, containerName: "atWork")
                self.atWorkImage = self.tempImage
                self.atWorkSelected = self.tempImage?.accessibilityIdentifier
            }
        }
        
    }
    
    private func initStyleSelected(selectedStyle: String, containerName: String) {
        var container: UIImageView?

        if (containerName == "relax") {
            container = self.areaRelax
        } else if (containerName == "onParty") {
            container = self.areaOnParty
        } else if (containerName == "atWork") {
            container = self.areaAtWork
        }
        
        if (selectedStyle == "sportwear"){
            self.tempImage = createCloneImage(self.sportwearIcon, location: nil, isInit: true)
        } else if (selectedStyle == "business"){
            self.tempImage = createCloneImage(self.businessIcon, location: nil, isInit: true)
        } else if (selectedStyle == "fashion"){
            self.tempImage = createCloneImage(self.fashionIcon, location: nil, isInit: true)
        } else if (selectedStyle == "casual"){
            self.tempImage = createCloneImage(self.casualIcon, location: nil, isInit: true)
        }
        if let _ = self.tempImage {
            self.tempImage!.center = container!.center
            self.view.addSubview(self.tempImage!)
        }
    }
    
    private func goBackArea(){
        let viewPoint = whichStyle(self.tempImage!)
        if let point = viewPoint {
            NSLog("Animation go back to park area")
            animationPark(CGPointMake(point.x, point.y))
        } else {
            NSLog("Remove uiImageView")
            self.tempImage!.removeFromSuperview()
        }
    }
    
    private func isAreaEmpty(container: UIImageView) -> Bool{
        if (container.accessibilityIdentifier == "atWork" && self.atWorkSelected != nil && !(self.atWorkSelected!.isEmpty)){
            return false
        } else if (container.accessibilityIdentifier == "relax" && self.relaxSelected != nil && !(self.relaxSelected!.isEmpty)){
            return false
        } else if (container.accessibilityIdentifier == "onParty" && self.onPartySelected != nil && !(self.onPartySelected!.isEmpty)){
            return false
        }
        return true
    }
    
    private func setStyleForArea(container: UIImageView, style: String){
        if (container.accessibilityIdentifier == "atWork"){
           self.atWorkSelected = style
        } else if (container.accessibilityIdentifier == "onParty"){
            self.onPartySelected = style
        } else if (container.accessibilityIdentifier == "relax"){
             self.relaxSelected = style
        }
    }
    
    private func createCloneImage(imageToClone: UIImageView, location: CGPoint?, isInit : Bool = false) -> UIImageView {
        let newImage = UIImageView(frame: imageToClone.frame)
        if (isInit){
            newImage.image = UIImage(named: getImageNameSelected(imageToClone.accessibilityIdentifier!))
        } else {
            newImage.image = imageToClone.image
        }
        newImage.accessibilityIdentifier = imageToClone.accessibilityIdentifier
        
        if let loc = location {
            newImage.center = CGPointMake(loc.x, loc.y)
        }
        return newImage
    }
    
    private func whichStyleSelected(location: CGPoint) -> UIImageView? {
        var viewPoint = sportwearIcon.convertPoint(location, fromView: self.view)
        if sportwearIcon.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "sportwear"
            return sportwearIcon
        }
        viewPoint = fashionIcon.convertPoint(location, fromView: self.view)
        if fashionIcon.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "fashion"
            return fashionIcon
        }
        viewPoint = businessIcon.convertPoint(location, fromView: self.view)
        if businessIcon.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "business"
            return businessIcon
        }
        viewPoint = casualIcon.convertPoint(location, fromView: self.view)
        if casualIcon.pointInside(viewPoint, withEvent: nil) {
            self.currentStyleSelected = "casual"
            return casualIcon
        }
        return nil
    }
    
    private func whichContainerSelected() -> UIImageView? {
        if (CGRectIntersectsRect(areaRelax.frame, self.tempImage!.frame)) {
            self.relaxImage = self.tempImage
            print("areaRelax")
            return areaRelax
        }
        if (CGRectIntersectsRect(areaAtWork.frame, self.tempImage!.frame)) {
            self.atWorkImage = self.tempImage
            print("areaAtWork")
            return areaAtWork
        }
        if (CGRectIntersectsRect(areaOnParty.frame, self.tempImage!.frame)) {
            self.onPartyImage = self.tempImage
            print("areaOnParty")
            return areaOnParty
        }
        return nil
    }
    
    private func whichStyle(image: UIImageView) -> CGPoint? {
        if (image.accessibilityIdentifier == "sportwear"){
            return sportwearIcon.center
        } else if (image.accessibilityIdentifier == "fashion"){
            return fashionIcon.center
        } else if (image.accessibilityIdentifier == "business"){
            return businessIcon.center
        } else if (image.accessibilityIdentifier == "casual"){
            return casualIcon.center
        }
        return nil
    }
    
    private func whichMomentSelected(location: CGPoint) -> UIImageView?{
        if let image = relaxImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                setStyleForArea(areaRelax, style: "")
                relaxImage = nil
                print("remove areaRelax")
                return image
            }
        }
        if let image = atWorkImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                setStyleForArea(areaAtWork, style: "")
                atWorkImage = nil
                print("remove atWorkImage")
                return image
            }
        }
        if let image = onPartyImage {
            let viewPoint = image.convertPoint(location, fromView: self.view)
            if image.pointInside(viewPoint, withEvent: nil){
                setStyleForArea(areaOnParty, style: "")
                onPartyImage = nil
                print("remove onPartyImage")
                return image
            }
        }
        return nil
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
    
    
    private func loginSuccess(profil: Profil, password: String){
        LoginService().Login(profil.email!, password: password) { (isSuccess, object) -> Void in
            if (isSuccess){
                let dal = ProfilsDAL()
                
                if let profil = dal.fetch(object["user"]["username"].string!.lowercaseString){
                    profil.access_token = object["access_token"].string
                    profil.refresh_token = object["refresh_token"].string
                    profil.expire_in = object["expires_in"].float
                    if let newProfil = dal.update(profil) {
                        SharedData.sharedInstance.currentUserId = newProfil.userid
                        SharedData.sharedInstance.sexe = newProfil.gender
                    }
                    dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("NavHomeViewController")
                        appDelegate.window?.rootViewController = initialViewController
                        appDelegate.window?.makeKeyAndVisible()
                    })
                }
            } else {
                ActivityLoader.shared.hideProgressView()
                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }
            
        }
        
    }
    
    private func animationEnd(destination: CGPoint){
        UIView.animateWithDuration(0.5, animations: {
            self.tempImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                if let _ = self.tempImage {
                    self.tempImage!.center = destination
                    self.tempImage!.image = UIImage(named: self.getImageNameSelected(self.tempImage!.accessibilityIdentifier!))
                }
                self.isMoving = false
        })
    }
    
    private func animationPark(destination: CGPoint){
        UIView.animateWithDuration(0.5, animations: {
            self.tempImage!.center = destination
            }, completion: { animationFinished in
                // when complete, remove the square from the parent view
                if let _ = self.tempImage {
                    self.tempImage!.removeFromSuperview()
                    self.tempImage = nil
                }
                self.isMoving = false
        })
        
    }
}