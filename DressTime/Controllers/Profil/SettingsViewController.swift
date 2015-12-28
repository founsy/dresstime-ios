//
//  SettingsViewController.swift
//  DressTime
//
//  Created by Fab on 01/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit




class SettingsViewController: UIViewController {
    private var user: Profil?
    private var tableViewController: SettingsTableViewController?
    private var confirmationView: ConfirmSave?
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        
        if let userSaving = self.user {
            if let vc = tableViewController {
                if (!isValidData()){
                    ActivityLoader.shared.hideProgressView()
                    let alert = UIAlertController(title: NSLocalizedString("settingsErrTitle", comment: ""), message: NSLocalizedString("settingsErrMessage", comment: ""), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("settingsErrButton", comment: ""), style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                    return
                }
                
                if (vc.menSelected){
                    userSaving.gender = "M"
                } else {
                    userSaving.gender = "F"
                }
                //Update SharedData
                SharedData.sharedInstance.sexe = userSaving.gender
                
                if (vc.temperatureField.selectedSegmentIndex == 0){
                    userSaving.temp_unit = "C"
                } else {
                    userSaving.temp_unit = "F"
                }
                
                if let email = vc.emailField.text {
                    userSaving.email = email
                }
                if let name = vc.nameField.text {
                    userSaving.name = name
                }
                
                UserService().UpdateUser(userSaving, completion: { (isSuccess, object) -> Void in
                    let profilDal = ProfilsDAL()
                    profilDal.update(userSaving)

                })
                
                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                
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
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            let loginBL = LoginBL()
            if let token = user.access_token {
                LoginService().Logout(user.access_token!, completion: { (isSuccess, object) -> Void in
                    loginBL.logoutWithSuccess(user)
                    self.goToLogin()
                })
            } else {
                loginBL.logoutWithSuccess(user)
                self.goToLogin()
            }
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            changeBackground(self.user!.gender!)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        print(self.confirmationView!.frame)
        print(UIScreen.mainScreen().bounds)
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50 - 65, 100, 100)
        print(self.confirmationView!.frame)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "settingTableView"){
            tableViewController = segue.destinationViewController as? SettingsTableViewController
            tableViewController?.delegate = self
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func changeBackground(sex: String){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            if (sex == "M"){
                self.backgroundView.image = UIImage(named: "ProfilsSettingBgdMen")
            } else {
                self.backgroundView.image = UIImage(named: "ProfilsSettingBgdWomen")
            }
        })
    }
    
    private func isValidData() -> Bool {
        return !((tableViewController!.emailField.text == nil || tableViewController!.emailField.text!.isEmpty) ||
                (tableViewController!.nameField.text == nil || tableViewController!.nameField.text!.isEmpty))
    }
    
    private func goToLogin(){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            let rootController:UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController")
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window!.makeKeyAndVisible()
            appDelegate.window!.rootViewController = rootController
            self.navigationController?.popToRootViewControllerAnimated(false)
        })
    }
}

extension SettingsViewController: SettingsTableViewControllerDelegate {
    func onSexeChange(sexe: String){
        changeBackground(sexe)
    }
}

