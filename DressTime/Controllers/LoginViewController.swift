//
//  LoginViewControllerNew.swift
//  DressTime
//
//  Created by Fab on 10/03/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: DTViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var buttonCollection: [UIButton]!

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var constraintContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTopStack: NSLayoutConstraint!
    @IBOutlet weak var constraintStackButtonTop: NSLayoutConstraint!
    @IBOutlet weak var hidePasswordButton: UIButton!
    
    private var userByFB: User?
    private var user: User?
    private var isRegister: Bool = true
    
    @IBAction func onTapRegister(sender: AnyObject) {
        if (isRegister){
            self.register()
        } else {
            self.login()
        }
    }
    
    @IBAction func onHidePasswordTapped(sender: AnyObject) {
        if (passwordField.secureTextEntry) {
            passwordField.secureTextEntry = false
            hidePasswordButton.selected = false
        } else {
            passwordField.secureTextEntry = true
            hidePasswordButton.selected = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.facebookButton.readPermissions = ["public_profile", "email", "user_friends"];
        self.facebookButton.delegate = self
        
        joinButton.layer.cornerRadius = joinButton.frame.height/2.0
        
        titleLabel.text = NSLocalizedString("loginTitle", comment: "Title")
        nameLabel.text = NSLocalizedString("loginName", comment: "Name")
        emailLabel.text = NSLocalizedString("loginEmail", comment: "Email")
        passwordLabel.text = NSLocalizedString("loginPassword", comment: "Password")
        orLabel.text = NSLocalizedString("loginOr", comment: "OR").uppercaseString
        
        signinButton.setTitle(NSLocalizedString("loginSignUpHeaderButton", comment: "SIGN IN").uppercaseString, forState: .Normal)
        signinButton.setTitle(NSLocalizedString("loginSignUpHeaderButton", comment: "SIGN IN").uppercaseString, forState: .Selected)
        
        loginButton.setTitle(NSLocalizedString("loginLoginHeaderButton", comment: "LOGIN").uppercaseString, forState: .Normal)
        loginButton.setTitle(NSLocalizedString("loginLoginHeaderButton", comment: "LOGIN").uppercaseString, forState: .Selected)
        
        joinButton.setTitle(NSLocalizedString("loginSignUpButton", comment: "LOGIN").uppercaseString, forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         drawBorderButton()
        let defaults = NSUserDefaults.standardUserDefaults()
        let alreadyLaunch = defaults.boolForKey("alreadyLaunch")
        if (!alreadyLaunch) {
            defaults.setValue(true, forKey: "alreadyLaunch")
            //Display Tutorial
            self.performSegueWithIdentifier("showTutorial", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectStyle") {
            if let viewController = segue.destinationViewController as? RegisterStyleViewController {
                viewController.user = self.user
            }
        } else if (segue.identifier == "showSexe") {
            if let viewController = segue.destinationViewController as? RegisterSexeViewController {
                viewController.user = self.user
            }
        }
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    private func drawBorderButton(){
        for (var i = 0; i < buttonCollection.count; i++){
            createBorder(buttonCollection[i], isSelect: buttonCollection[i].selected)
            buttonCollection[i].addTarget(self, action: "createBorderButton:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func createBorderButton(btn: UIButton){
        removeBorder()
        btn.selected = true
        for (var i = 0; i < buttonCollection.count; i++){
            createBorder(buttonCollection[i], isSelect: buttonCollection[i].selected)
            if (btn == loginButton){
                isRegister = false
                joinButton.setTitle(NSLocalizedString("loginLoginButton", comment: "LOGIN").uppercaseString, forState: .Normal)
                nameView.hidden = true
                constraintContainerHeight.constant = 150.0
                constraintTopStack.constant = nameView.frame.height//(280.0-150.0)/2.0
            } else {
                isRegister = true
                joinButton.setTitle(NSLocalizedString("loginSignUpButton", comment: "JOIN US").uppercaseString, forState: .Normal)
                nameView.hidden = false
                constraintContainerHeight.constant = 280.0
                constraintTopStack.constant = 0.0
                constraintStackButtonTop.constant = 30.0
            }
        }
    }
    
    private func showError(titleKey: String, messageKey: String, buttonKey: String, handler: ((UIAlertAction) -> Void)?){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            let alert = UIAlertController(title: NSLocalizedString(titleKey, comment: ""), message: NSLocalizedString(messageKey, comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(buttonKey, comment: ""), style: .Default, handler: handler))
            self.presentViewController(alert, animated: true){}
        })
    }
    
    private func createBorder(btn: UIButton, isSelect: Bool){
        let height:CGFloat = isSelect ? 3.0 : 1.0
        let color = UIColor.whiteColor()
        let lineView = UIView(frame: CGRectMake(0, btn.frame.size.height - height, UIScreen.mainScreen().bounds.width/2.0, height))
        lineView.backgroundColor = color
        btn.addSubview(lineView)
    }
    
    private func removeBorder(){
        for (var i = 0; i < buttonCollection.count; i++){
            buttonCollection[i].selected = false
            for subView in buttonCollection[i].subviews {
                if (!subView.isKindOfClass(UILabel)){
                    subView.removeFromSuperview()
                }
            }
        }
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

extension LoginViewController {
    private func login(){
        if let login = emailField.text {
            if let password = passwordField.text {
                if (login.isEmpty || password.isEmpty){
                    self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                    return
                }
                
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
                                    LoginService().SendVerificationEmail(self.emailField.text!, completion: { (isSuccess, object) -> Void in
                                        print("Email Send");
                                    });
                                }));
                                alert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action) -> Void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }))
                                self.presentViewController(alert, animated: true){}
                            }
                        } else {
                            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    private func register(){
        let name = nameField.text, email = emailField.text, password = passwordField.text;
        if ((isRegister && name == nil || name == "") || email == nil || email == "" || password == nil || password == ""){
            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
            return
        } else if (!isValidEmail(email!)){
            self.showError("loginErrTitle", messageKey:  "loginErrMessage", buttonKey:  "loginErrButton", handler: nil)
            return
        }else {
            self.user = User(email: email!, username: email!, displayName: name!)
            self.user!.password = password
            self.performSegueWithIdentifier("showSexe", sender: self)
        
        }
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
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
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("RegisterStyleViewController") as! RegisterStyleViewController
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