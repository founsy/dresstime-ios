//
//  SelectStyleViewController.swift
//  DressTime
//
//  Created by Fab on 7/24/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Mixpanel

enum Style : String {
    case CasualChic = "casual"
    case Fashion = "fashion"
    case Sportwear = "sportwear"
    case Business = "business"
}

class SelectStyleViewController: DTViewController {
    
    private var selectedStyle = [String]()
    private var confirmationView: ConfirmSave?
    
    var currentUserId: String?
    var user: User?
    
    @IBOutlet weak var fashionbutton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var sportWearButton: UIButton!
    @IBOutlet weak var casualChicButton: UIButton!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var selectStyleLabel: UILabel!
    @IBOutlet weak var fashionLabel: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var sportwearLabel: UILabel!
    @IBOutlet weak var casualChicLabel: UILabel!
    
    
    @IBAction func buttonsStyle(sender: AnyObject) {
        if (sender === fashionbutton){
            fashionbutton.selected = !fashionbutton.selected
            if (!selectedStyle.contains(Style.Fashion.rawValue)){
                selectedStyle.append(Style.Fashion.rawValue)
            } else {
                if let index = selectedStyle.indexOf(Style.Fashion.rawValue) {
                    selectedStyle.removeAtIndex(index)
                }

            }
        } else if (sender === businessButton){
            businessButton.selected = !businessButton.selected
            
            if (!selectedStyle.contains(Style.Business.rawValue)){
                selectedStyle.append(Style.Business.rawValue)
            } else {
                if let index = selectedStyle.indexOf(Style.Business.rawValue) {
                    selectedStyle.removeAtIndex(index)
                }
                
            }
        } else if (sender === sportWearButton){
            sportWearButton.selected = !sportWearButton.selected
            
            if (!selectedStyle.contains(Style.Sportwear.rawValue)){
                selectedStyle.append(Style.Sportwear.rawValue)
            } else {
                if let index = selectedStyle.indexOf(Style.Sportwear.rawValue) {
                    selectedStyle.removeAtIndex(index)
                }
                
            }
        } else if (sender === casualChicButton){
            casualChicButton.selected = !casualChicButton.selected
            
            if (!selectedStyle.contains(Style.CasualChic.rawValue)){
                selectedStyle.append(Style.CasualChic.rawValue)
            } else {
                if let index = selectedStyle.indexOf(Style.CasualChic.rawValue) {
                    selectedStyle.removeAtIndex(index)
                }
            }
        }
        validationButton.enabled = !(selectedStyle.count == 0) //TODO - Change color when button is disabled
        if (validationButton.enabled) {
            validationButton.backgroundColor = UIColor.dressTimeRed()
        } else {
            validationButton.backgroundColor = UIColor.dressTimeRedDisabled()
        }
    }
    
    @IBAction func onValidatationTapped(sender: AnyObject) {
        //Update Current User
        if let userId = currentUserId {
            modifyUser(userId)
        } else { //Create new User
            createUser()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterStyle"
        self.navigationController?.navigationBarHidden = false
        
        if let userId = currentUserId {
            let dal = ProfilsDAL()
            if let profil = dal.fetch(userId) {
                if let stylesStr = profil.styles {
                    self.selectedStyle = stylesStr.componentsSeparatedByString(",")
                    for var item in self.selectedStyle {
                        switch(item) {
                        case Style.Business.rawValue:
                            businessButton.selected = true
                        case Style.CasualChic.rawValue:
                            casualChicButton.selected = true
                        case Style.Fashion.rawValue:
                            fashionbutton.selected = true
                        case Style.Sportwear.rawValue:
                            sportWearButton.selected = true
                        default:
                            print("No style")
                        }
                    }
                }
                
            } else {
              //  validationButton.enabled = false
            }
        }
        
        self.createConfirmationView()
        
    }
    
    private func setLocalization(){
        validationButton.setTitle(NSLocalizedString("styleSelectionValidationButton", comment: ""), forState: .Normal)
        selectStyleLabel.text = NSLocalizedString("styleSelectionStyleLabel", comment: "").uppercaseString
        fashionLabel.text = NSLocalizedString("styleSelectionFashionLabel", comment: "")
        businessLabel.text = NSLocalizedString("styleSelectionBusinessLabel", comment: "")
        sportwearLabel.text = NSLocalizedString("styleSelectionSportwearLabel", comment: "")
        casualChicLabel.text = NSLocalizedString("styleSelectionCasualChicLabel", comment: "")
    }
    
    private func createConfirmationView(){
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50, 100, 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    private func createUser(){
        if let newUser = self.user {
            let dal = ProfilsDAL()
            newUser.styles = self.selectedStyle.joinWithSeparator(",")            
            
            if let profil = dal.save(newUser) {
                
                UserService().CreateUser(profil, password: newUser.password, completion: { (isSuccess, object) -> Void in
                    if (isSuccess){
                        //Create Model
                        if (FBSDKAccessToken.currentAccessToken() == nil){
                            self.loginSuccess(profil, password: newUser.password!)
                        } else {
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(profil.userid, forKey: "userId")
                            defaults.synchronize()
                        }
                        SharedData.sharedInstance.currentUserId = profil.userid
                        SharedData.sharedInstance.sexe = profil.gender
                        
                        let mixpanel = Mixpanel.sharedInstance()
                        mixpanel.people.set(["$name" : profil.lastName!, "firstname": profil.firstName!, "$email" : profil.email!, "Styles": profil.styles!,"Notification" : Notification.morning.rawValue])
                        
                        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                            self.confirmationView?.alpha = 1
                            self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                            }, completion: { (isFinish) -> Void in
                                UIView.animateWithDuration(0.2, animations: { () -> Void in
                                    self.confirmationView?.alpha = 0
                                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                                    }, completion: { (finish) -> Void in
                                        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("NavHomeViewController")
                                            appDelegate.window?.rootViewController = initialViewController
                                            appDelegate.window?.makeKeyAndVisible()
                                        })
                                })
                        })
                        
                    } else {
                        if (object["code"].numberValue == 11000){
                            //TODO - Duplication Key (email)
                            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.CreateAccount_Email_Duplicate, object: nil)
                        } else if (object["name"].stringValue == "ValidationError") {
                            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.CreateAccount_Style_Required, object: nil)
                        } else {
                            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.Error.CreateAccount, object: nil)
                        }
                        return
                    }
                })
                
            }
        }
    }
    
    private func modifyUser(userId: String){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userId) {
            profil.styles = self.selectedStyle.joinWithSeparator(",")
            
            let newProfil = dal.update(profil)
            UserService().UpdateUser(newProfil!, completion: { (isSuccess, object) -> Void in
                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                self.view.bringSubviewToFront(self.confirmationView!)
                
                UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                    self.confirmationView?.alpha = 1
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                    }, completion: { (isFinish) -> Void in
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.confirmationView?.alpha = 0
                            self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                            }, completion: { (finish) -> Void in
                                self.navigationController?.popViewControllerAnimated(true)
                        })
                })
            })
            
            
        }
    }
    
    private func loginSuccess(profil: Profil, password: String){
        LoginService().Login(profil.email!, password: password) { (isSuccess, object) -> Void in
            if (isSuccess){
                let loginBL = LoginBL();
                loginBL.loginWithSuccess(object)
            } else {
                ActivityLoader.shared.hideProgressView()
                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }
            
        }
        
    }
    
}