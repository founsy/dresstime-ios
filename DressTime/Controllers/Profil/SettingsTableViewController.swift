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
    func onSexeChange(_ sexe: String)
    func settingsTableViewLogout(_ isLogout: Bool)
}

class SettingsTableViewController: UITableViewController {
    
    var user: Profil?
    var delegate: SettingsTableViewControllerDelegate?
    var menSelected = true
    
    fileprivate var confirmationView: ConfirmSave?
    
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
    
    
    @IBAction func onLogoutTapped(_ sender: AnyObject) {
        self.logout()
    }
    
    @IBAction func unlinkTapped(_ sender: AnyObject) {
        let loginBL = LoginBL()
        loginBL.unmergeProfilWithFacebook(self.user!) { (isSuccess) -> Void in
            FBSDKLoginManager().logOut()
        }
    }
    
    @IBAction func onDoneTapped(_ sender: AnyObject) {
        
        if let userSaving = self.user {
            if (!isValidData()){
                ActivityLoader.shared.hideProgressView()
                let alert = UIAlertController(title: NSLocalizedString("settingsErrTitle", comment: ""), message: NSLocalizedString("settingsErrMessage", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("settingsErrButton", comment: ""), style: .default) { _ in })
                self.present(alert, animated: true){}
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
                _ = profilDal.update(userSaving)
                let mixpanel = Mixpanel.sharedInstance()
                mixpanel.people.set(["$name" : userSaving.lastName!, "firstname": userSaving.firstName!, "$email" : userSaving.email!, "Notification" : userSaving.notification!])
                
            })
            
            self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                self.confirmationView?.alpha = 1
                self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                }, completion: { (isFinish) -> Void in
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        self.confirmationView?.alpha = 0
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                        }, completion: { (finish) -> Void in
                            _ = self.navigationController?.popViewController(animated: true)
                    })
            })
        }
    }
    
    @IBAction func onGenderSelected(_ sender: AnyObject) {
        self.menSelected = !self.menSelected
        if (self.menSelected) {
            menButton.setTitle("I'm a Men".uppercased(), for: UIControlState())
        } else {
            menButton.setTitle("I'm a women".uppercased(), for: UIControlState())
        }
        
        if let del = delegate {
            var sexe = "F"
            if (self.menSelected){
                sexe = "M"
            }
            del.onSexeChange(sexe)
        }
    }
    
    @IBAction func onNotificationTapped(_ sender: AnyObject) {
        morningNotification.isSelected = (sender === morningNotification)
        noonNotification.isSelected = (sender === noonNotification)
        eveningNotification.isSelected = (sender === eveningNotification)
        setStyleButton(morningNotification, isSelected: morningNotification.isSelected)
        setStyleButton(noonNotification, isSelected: noonNotification.isSelected)
        setStyleButton(eveningNotification, isSelected: eveningNotification.isSelected)
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
        profilImage.image = UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercased())")
        profilImage.layer.shadowColor = UIColor.black.cgColor
        profilImage.layer.shadowOffset = CGSize(width: 0, height: 1)
        profilImage.layer.shadowOpacity = 0.50
        profilImage.layer.shadowRadius = 4
        profilImage.contentMode = .scaleToFill
        profilImage.layer.cornerRadius = 36.0
        profilImage.clipsToBounds = true
        
        morningNotification.layer.cornerRadius = 8.0
        noonNotification.layer.cornerRadius = 8.0
        eveningNotification.layer.cornerRadius = 8.0
        createBorderNotification(leftNotificationView, roudingsCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft])
        createBorderNotification(rightNotificationView, roudingsCorners: [UIRectCorner.topRight, UIRectCorner.bottomRight])

        setStyleButton(morningNotification, isSelected: morningNotification.isSelected)
        setStyleButton(noonNotification, isSelected: noonNotification.isSelected)
        setStyleButton(eveningNotification, isSelected: eveningNotification.isSelected)
        
        if let profil_image = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!)?.picture{
            profilImage.image = UIImage(data: profil_image)
        } else {
            profilImage.image = UIImage(named: "profile\(SharedData.sharedInstance.sexe!.uppercased())")
        }

        fbLoginButton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Wardrobe", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        titleItem.title = NSLocalizedString("Informations", comment: "Informations")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.confirmationView = Bundle.main.loadNibNamed("ConfirmSave", owner: self, options: nil)?[0] as? ConfirmSave
        self.confirmationView!.frame = CGRect(x: UIScreen.main.bounds.size.width/2.0 - 50, y: UIScreen.main.bounds.size.height/2.0 - 50, width: 100, height: 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    
    fileprivate func createBorderNotification(_ view: UIView, roudingsCorners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: roudingsCorners, cornerRadii: CGSize(width: 8.0, height: 8.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
    }
    
    fileprivate func isValidData() -> Bool {
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
    
    fileprivate func goToLogin(){
        DispatchQueue.main.async(execute: { () -> Void in
            let rootController:UIViewController = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigationController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.makeKeyAndVisible()
            appDelegate.window!.rootViewController = rootController
            _ = self.navigationController?.popToRootViewController(animated: false)
        })
    }
    
    fileprivate func setStyleButton(_ button: UIButton, isSelected: Bool){
        if (isSelected) {
            button.backgroundColor = UIColor.dressTimeRed()
            button.tintColor = UIColor.white
            button.layer.borderColor = UIColor.dressTimeRed().cgColor
            button.layer.borderWidth = 0
        } else {
            button.backgroundColor = UIColor.clear
            button.tintColor = UIColor.dressTimeRed()
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.dressTimeRed().cgColor
        }
    }
    
    fileprivate func getNotification() -> String? {
        if (morningNotification.isSelected){
            return NotificationTime.morning.rawValue
        } else if (noonNotification.isSelected){
            return NotificationTime.noon.rawValue
        } else if (eveningNotification.isSelected){
            return NotificationTime.evening.rawValue
        } else {
            return nil
        }
    }
    
    fileprivate func setNotification(_ notification: String?) {
        if let notif = notification {
            if (NotificationTime.morning.rawValue == notif){
                morningNotification.isSelected = true
            } else if (NotificationTime.noon.rawValue == notif){
                noonNotification.isSelected = true
            } else if (NotificationTime.evening.rawValue == notif){
                eveningNotification.isSelected = true
            }
        }
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingsTableViewController : FBSDKLoginButtonDelegate {
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        /*let loginBL = LoginBL()
        loginBL.unmergeProfilWithFacebook(self.user!) */
    }
    
}
