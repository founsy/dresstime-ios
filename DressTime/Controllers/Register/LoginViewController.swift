//
//  LoginViewController.swift
//  login
//
//  Created by Fabian Langlet on 7/19/16.
//  Copyright © 2016 Fabian Langlet. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController : UIViewController {
    private var userByFB: User?
    private var user: User?
    
    @IBOutlet weak var letsGo: UIButton!
    @IBOutlet weak var email: DTTextField!
    @IBOutlet weak var password: DTTextField!
    @IBOutlet weak var labelOr: UILabel!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!

    @IBAction func onLetsGoTapped(sender: AnyObject) {
        self.login(email.text, password: password.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        letsGo.layer.cornerRadius = 3.0
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        setLocalization()
        
    }
    
    private func setLocalization(){
        letsGo.setTitle(NSLocalizedString("loginLetsGoButton", comment: "Let's go"), forState: .Normal)
        labelOr.text = NSLocalizedString("loginEmailOr", comment: "Or")
    }
    
    
    private func showError(titleKey: String, messageKey: String, buttonKey: String, handler: ((UIAlertAction) -> Void)?){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            let alert = UIAlertController(title: NSLocalizedString(titleKey, comment: ""), message: NSLocalizedString(messageKey, comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(buttonKey, comment: ""), style: .Default, handler: handler))
            self.presentViewController(alert, animated: true){}
        })
    }
    
    private func goToHome(){
        ActivityLoader.shared.hideProgressView()
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("NavHomeViewController")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        })
    }

}

extension LoginViewController : DressingSynchroDelegate {
    func dressingSynchro(dressingSynchro: DressingSynchro, syncDidFinish isFinish: Bool) {
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            self.goToHome()
        })
        
    }
    
    func dressingSynchro(dressingSynchro: DressingSynchro, synchingProgressing currentValue: Int, totalNumber: Int) {
        ActivityLoader.shared.setLabel("Synching \(currentValue)/\(totalNumber) clothes")
    }
}

extension LoginViewController {
    private func login(email: String?, password: String?){
        if let login = email {
            if let newPassword = password {
                if (login.isEmpty || newPassword.isEmpty){
                    self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                    return
                }
                
                view.endEditing(true)
                ActivityLoader.shared.showProgressView(self.view)
                LoginService().Login(login, password: newPassword) { (isSuccess, object) -> Void in
                    if (isSuccess){
                        let loginBL = LoginBL()
                        loginBL.loginWithSuccess(object)
                        
                        //Check after login, if a synchro is necessary
                        //Today, only if Local database is empty
                        //TODO - Tomorrow, syncro differential
                        let dressingSynchro = DressingSynchro(userId: SharedData.sharedInstance.currentUserId!)
                        dressingSynchro.delagate = self
                        dressingSynchro.execute({ (isNeeded) -> Void in
                            if (!isNeeded){
                                self.goToHome()
                            }
                        })
                    } else {
                        ActivityLoader.shared.hideProgressView()
                        if let err_desc = object["error_description"].string {
                            if (err_desc == "001"){
                                print("Please validate your account");
                                let alert = UIAlertController(title: "Account not validate", message: "Please validate your account! Do you want to send again the email?", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "Resend", style: .Default, handler: { (action) -> Void in
                                    //Resend Validation Email
                                    LoginService().SendVerificationEmail(login, completion: { (isSuccess, object) -> Void in
                                        print("Email Send");
                                    });
                                }));
                                alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }))
                                self.presentViewController(alert, animated: true){}
                            } else {
                                self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                            }
                        } else {
                            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
}

extension LoginViewController : FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        if ((error) != nil){
            // Process error
            print(error)
            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Cancelled")
            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                UserService().GetUser({ (isSuccess, object) -> Void in
                    let loginBL = LoginBL()
                    if (isSuccess){
                        //If into object provider is Facebook, meaning no account still exists on our system
                        if let _ = object["provider"].string {
                            self.userByFB = loginBL.loginFacebookWithSuccess(object)
                            if let url = self.userByFB?.picture {
                                self.userByFB?.picture_data = NSData(contentsOfURL: NSURL(string: url)!)
                            }
                            let storyboard = UIStoryboard(name: "Register", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("SelectStyleViewController") as! SelectStyleViewController
                            vc.user = self.userByFB
                            self.presentViewController(vc, animated: true, completion: nil)
                        } else {
                            //Otherwise find an account go to Home
                            loginBL.loginWithSuccess(object)
                            self.goToHome();
                        }
                    } else {
                        self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                    }
                })
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
}