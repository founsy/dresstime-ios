//
//  LoginViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class LoginViewController: DTViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginWithFacebook: FBSDKLoginButton!
    
    private var userByFB: User?
    
    @IBAction func onClickLoginBtn(sender: AnyObject) {
        if let login = loginText.text {
            if let password = passwordText.text {
                view.endEditing(true)
                ActivityLoader.shared.showProgressView(self.view)
                LoginService().Login(login, password: password) { (isSuccess, object) -> Void in
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
                                    LoginService().SendVerificationEmail(self.loginText.text!, completion: { (isSuccess, object) -> Void in
                                        print("Email Send");
                                    });
                                }));
                                alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }))
                                self.presentViewController(alert, animated: true){}
                            } else {
                                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                                self.presentViewController(alert, animated: true){}
                            }
                        }
                       
                    }
                    
                }
            }
        }
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
        self.classNameAnalytics = "Home"
        
        passwordText.secureTextEntry = true
        self.navigationController?.navigationBarHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.loginWithFacebook.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        let alreadyLaunch = defaults.boolForKey("alreadyLaunch")
        if (!alreadyLaunch) {
            defaults.setValue(true, forKey: "alreadyLaunch")
            //Display Tutorial
            self.performSegueWithIdentifier("showTutorial", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStyle"){
            let vc = segue.destinationViewController as! UINavigationController
            if let styleVC = vc.topViewController as? RegisterStyleViewController {
                styleVC.user = self.userByFB
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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

extension LoginViewController: DressingSynchroDelegate {
    func dressingSynchro(dressingSynchro: DressingSynchro, syncDidFinish isFinish: Bool) {
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            self.goToHome()
        })

    }
    
    func dressingSynchro(dressingSynchro: DressingSynchro, synchingProgressing currentValue: Int, totalNumber: Int) {
        ActivityLoader.shared.setLabel("Synching \(currentValue)/\(totalNumber) clothes")
    }
}

extension LoginViewController : FBSDKLoginButtonDelegate {
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
                UserService().GetUser({ (isSuccess, object) -> Void in
                    let loginBL = LoginBL()
                    if (isSuccess){
                        //If into object provider is Facebook, meaning no account still exists on our system
                        if let _ = object["provider"].string {
                            self.userByFB = loginBL.loginFacebookWithSuccess(object)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("RegisterStyleViewController") as! RegisterStyleViewController
                            vc.user = self.userByFB
                            self.presentViewController(vc, animated: true, completion: nil)
                        } else {
                            //Otherwise find an account go to Home
                            loginBL.loginWithSuccess(object)
                            self.goToHome();
                        }
                    }
                })
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
}