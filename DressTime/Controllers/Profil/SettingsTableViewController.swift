//
//  NewSettingsTableViewController.swift
//  DressTime
//
//  Created by Fab on 11/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Mixpanel

protocol SettingsTableViewControllerDelegate {
    func onSexeChange(sexe: String)
    func settingsTableViewLogout(isLogout: Bool)
}

class SettingsTableViewController: UITableViewController {
    
    var user: Profil?
    var delegate: SettingsTableViewControllerDelegate?
    var menSelected = true
    
    private var confirmationView: ConfirmSave?
    
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var profilImage: UIImageView!
    @IBOutlet weak var firstName: DTTextField!
    @IBOutlet weak var nameField: DTTextField!
    @IBOutlet weak var emailField: DTTextField!
    @IBOutlet weak var temperatureField: UISegmentedControl!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var morningNotification: UIButton!
    @IBOutlet weak var noonNotification: UIButton!
    @IBOutlet weak var eveningNotification: UIButton!
    @IBOutlet weak var notificationStackView: UIStackView!
    @IBOutlet weak var leftNotificationView: UIView!
    @IBOutlet weak var rightNotificationView: UIView!
    
    
    @IBAction func onLogoutTapped(sender: AnyObject) {
        self.logout()
    }
    
    @IBAction func unlinkTapped(sender: AnyObject) {
        let loginBL = LoginBL()
        loginBL.unmergeProfilWithFacebook(self.user!) { (isSuccess) -> Void in
            FBSDKLoginManager().logOut()
        }
    }
    
    @IBAction func onDoneTapped(sender: AnyObject) {
        
        if let userSaving = self.user {
            if (!isValidData()){
                ActivityLoader.shared.hideProgressView()
                let alert = UIAlertController(title: NSLocalizedString("settingsErrTitle", comment: ""), message: NSLocalizedString("settingsErrMessage", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("settingsErrButton", comment: ""), style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
                return
            }
            
            if (self.menSelected){
                userSaving.gender = "M"
            } else {
                userSaving.gender = "F"
            }
            //Update SharedData
            SharedData.sharedInstance.sexe = userSaving.gender
            
            if (self.temperatureField.selectedSegmentIndex == 0){
                userSaving.temp_unit = "C"
            } else {
                userSaving.temp_unit = "F"
            }
            
            if let email = self.emailField.text {
                userSaving.email = email
            }
            
            if let name = self.nameField.text {
                userSaving.lastName = name
                userSaving.name = name
            }
            
            if let firstName = self.firstName.text {
                userSaving.firstName = firstName
            }
            
            if let notification = self.getNotification() {
                userSaving.notification = notification
            }
            
            UserService().UpdateUser(userSaving, completion: { (isSuccess, object) -> Void in
                let profilDal = ProfilsDAL()
                profilDal.update(userSaving)
                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.people.set(["$name" : userSaving.lastName!, "firstname": userSaving.firstName!, "$email" : userSaving.email!, "Notification" : userSaving.notification!])
                
            })
            
            self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
            
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
        }
    }
    
    @IBAction func onGenderSelected(sender: AnyObject) {
        self.menSelected = !self.menSelected
        if (self.menSelected) {
            menButton.setTitle("I'm a Men".uppercaseString, forState: .Normal)
        } else {
            menButton.setTitle("I'm a women".uppercaseString, forState: .Normal)
        }
        
        if let del = delegate {
            var sexe = "F"
            if (self.menSelected){
                sexe = "M"
            }
            del.onSexeChange(sexe)
        }
    }
    
    @IBAction func onNotificationTapped(sender: AnyObject) {
        morningNotification.selected = (sender === morningNotification)
        noonNotification.selected = (sender === noonNotification)
        eveningNotification.selected = (sender === eveningNotification)
        setStyleButton(morningNotification, isSelected: morningNotification.selected)
        setStyleButton(noonNotification, isSelected: noonNotification.selected)
        setStyleButton(eveningNotification, isSelected: eveningNotification.selected)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            firstName.text = user.firstName
            nameField.text = user.lastName
            emailField.text = user.email
            if (user.temp_unit == "C"){
                temperatureField.selectedSegmentIndex = 0
            } else {
                 temperatureField.selectedSegmentIndex = 1
            }
            self.menSelected = (user.gender == "M")
        }
        currentPasswordField.text = "passwordDressTime"
        setNotification(user?.notification)
        
        //currentPasswordField.clearsOnBeginEditing = true
        
        nameField.delegate = self
        emailField.delegate = self
        currentPasswordField.delegate = self
        newPasswordField.delegate = self
        profilImage.image = UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercaseString)")
        profilImage.layer.shadowColor = UIColor.blackColor().CGColor
        profilImage.layer.shadowOffset = CGSizeMake(0, 1)
        profilImage.layer.shadowOpacity = 0.50
        profilImage.layer.shadowRadius = 4
        profilImage.contentMode = .ScaleToFill
        profilImage.layer.cornerRadius = 36.0
        profilImage.clipsToBounds = true
        
        morningNotification.layer.cornerRadius = 8.0
        noonNotification.layer.cornerRadius = 8.0
        eveningNotification.layer.cornerRadius = 8.0
        createBorderNotification(leftNotificationView, roudingsCorners: [UIRectCorner.TopLeft, UIRectCorner.BottomLeft])
        createBorderNotification(rightNotificationView, roudingsCorners: [UIRectCorner.TopRight, UIRectCorner.BottomRight])

        setStyleButton(morningNotification, isSelected: morningNotification.selected)
        setStyleButton(noonNotification, isSelected: noonNotification.selected)
        setStyleButton(eveningNotification, isSelected: eveningNotification.selected)
        
        if let profil_image = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!)?.picture{
            profilImage.image = UIImage(data: profil_image)
        } else {
            profilImage.image = UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercaseString)")
        }

        fbLoginButton.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Wardrobe", style: .Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        titleItem.title = NSLocalizedString("Informations", comment: "Informations")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50, 100, 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    
    private func createBorderNotification(view: UIView, roudingsCorners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: roudingsCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
    }
    
    private func isValidData() -> Bool {
        return !((self.emailField.text == nil || self.emailField.text!.isEmpty) ||
            (self.nameField.text == nil || self.nameField.text!.isEmpty) ||
            (getNotification() == nil))
        
    }
    
    func logout() {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            let loginBL = LoginBL()
            if let token = user.access_token {
                LoginService().Logout(token, completion: { (isSuccess, object) -> Void in
                    loginBL.logoutWithSuccess(user)
                    self.goToLogin()
                })
            } else {
                loginBL.logoutWithSuccess(user)
                self.goToLogin()
            }
            
        }
    }
    
    private func goToLogin(){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            let rootController:UIViewController = UIStoryboard(name: "Register", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginNavigationController")
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window!.makeKeyAndVisible()
            appDelegate.window!.rootViewController = rootController
            self.navigationController?.popToRootViewControllerAnimated(false)
        })
    }
    
    private func setStyleButton(button: UIButton, isSelected: Bool){
        if (isSelected) {
            button.backgroundColor = UIColor.dressTimeRed()
            button.tintColor = UIColor.whiteColor()
            button.layer.borderColor = UIColor.dressTimeRed().CGColor
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = UIColor.clearColor()
            button.tintColor = UIColor.dressTimeRed()
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.dressTimeRed().CGColor
        }
    }
    
    private func getNotification() -> String? {
        if (morningNotification.selected){
            return Notification.morning.rawValue
        } else if (noonNotification.selected){
            return Notification.noon.rawValue
        } else if (eveningNotification.selected){
            return Notification.evening.rawValue
        } else {
            return nil
        }
    }
    
    private func setNotification(notification: String?) {
        if let notif = notification {
            if (Notification.morning.rawValue == notif){
                morningNotification.selected = true
            } else if (Notification.noon.rawValue == notif){
                noonNotification.selected = true
            } else if (Notification.evening.rawValue == notif){
                eveningNotification.selected = true
            }
        }
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingsTableViewController : FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        if ((error) != nil){
            // Process error
            print(error)
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Cancelled")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                let loginBL = LoginBL()
                loginBL.mergeProfilWithFacebook(self.user!)
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        /*let loginBL = LoginBL()
        loginBL.unmergeProfilWithFacebook(self.user!) */
    }
    
}
