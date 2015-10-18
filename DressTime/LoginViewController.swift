//
//  LoginViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func onClickLoginBtn(sender: AnyObject) {
        var json = [String: AnyObject]()
        json["grant_type"] = "password"
        json["client_id"] = "android"
        json["client_secret"] = "SomeRandomCharsAndNumbers"
        json["username"] = loginText.text
        json["password"] = passwordText.text
        
        
        
        view.endEditing(true)
        LoginService().Login(loginText.text!, password: passwordText.text!) { (isSuccess, object) -> Void in
            if (isSuccess){
                let dal = ProfilsDAL()
                
                if let profil = dal.fetch(self.loginText.text!){
                    profil.access_token = object["access_token"].string
                    profil.refresh_token = object["refresh_token"].string
                    profil.expire_in = object["expires_in"].float
                    if let newProfil = dal.update(profil) {
                        SharedData.sharedInstance.currentUserId = newProfil.userid
                        SharedData.sharedInstance.sexe = newProfil.gender
                    }
                } else {
                    let pro = dal.save(self.loginText.text!, access_token:  object["access_token"].string!, refresh_token: object["refresh_token"].string!, expire_in: object["expires_in"].int!, name: self.loginText.text!, gender: "M", temp_unit: "C");
                    SharedData.sharedInstance.currentUserId = pro.userid
                    SharedData.sharedInstance.sexe = pro.gender
                }
                
                //Check after login, if a synchro is necessary
                //Today, only if Local database is empty
                //TODO - Tomorrow, syncro differential
                let dressingSynchro = DressingSynchro(userId: SharedData.sharedInstance.currentUserId!)
                dressingSynchro.execute()
                
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    
                    let appDelegateTemp = UIApplication.sharedApplication().delegate;
                    appDelegateTemp!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                })
            } else {
                let alert = UIAlertView(title: "Failed!", message:"Error during the login the processs", delegate: nil, cancelButtonTitle: "Okay.")
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
            }

        }
        
        
     /*   LoginService.loginMethod(json, postCompleted: { (succeeded: Bool, msg: [String: AnyObject]) -> () in
            if (succeeded){
                let dal = ProfilsDAL()
                if let profil = dal.fetch(self.loginText.text!){
                    profil.access_token = msg["access_token"] as? String
                    profil.refresh_token = msg["refresh_token"] as? String
                    profil.expire_in = msg["expires_in"] as? NSNumber
                    if let newProfil = dal.update(profil) {
                        SharedData.sharedInstance.currentUserId = newProfil.userid
                    }
                } else {
                    let pro = dal.save(self.loginText.text!, access_token: msg["access_token"] as! String, refresh_token: msg["refresh_token"] as! String, expire_in: msg["expires_in"] as! Int, name: self.loginText.text!, gender: "M", temp_unit: "C");
                    SharedData.sharedInstance.currentUserId = pro.userid
                }
                
                //Check after login, if a synchro is necessary
                //Today, only if Local database is empty
                //TODO - Tomorrow, syncro differential
                let dressingSynchro = DressingSynchro(userId: SharedData.sharedInstance.currentUserId!)
                dressingSynchro.execute()
                
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    
                    let appDelegateTemp = UIApplication.sharedApplication().delegate;
                    appDelegateTemp!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                })
                
            } else {
                let alert = UIAlertView(title: "Failed!", message: msg["error"] as? String, delegate: nil, cancelButtonTitle: "Okay.")
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
            }
        }) */
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {        
        if(textField.returnKeyType == UIReturnKeyType.Next) {
            let nextTag: Int = textField.tag + 1
            let nextField: UITextField = textField.superview?.viewWithTag(nextTag) as! UITextField
            nextField.becomeFirstResponder()
            return true
        }
        else if(textField.returnKeyType == UIReturnKeyType.Go) {
            self.onClickLoginBtn(self.view)
            return true
        }
        else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.secureTextEntry = true
        self.navigationController?.navigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
