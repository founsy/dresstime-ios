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
    fileprivate var userByFB: User?
    fileprivate var user: User?
    
    @IBOutlet weak var letsGo: UIButton!
    @IBOutlet weak var email: DTTextField!
    @IBOutlet weak var password: DTTextField!
    @IBOutlet weak var labelOr: UILabel!
    @IBOutlet weak var facebookButton: FBSDKLoginButton!

    @IBAction func onLetsGoTapped(_ sender: AnyObject) {
        self.login(email.text, password: password.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        letsGo.layer.cornerRadius = 3.0
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        setLocalization()
        
    }
    
    fileprivate func setLocalization(){
        letsGo.setTitle(NSLocalizedString("loginLetsGoButton", comment: "Let's go"), for: UIControlState())
        labelOr.text = NSLocalizedString("loginEmailOr", comment: "Or")
    }
    
    
    fileprivate func showError(_ titleKey: String, messageKey: String, buttonKey: String, handler: ((UIAlertAction) -> Void)?){
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: NSLocalizedString(titleKey, comment: ""), message: NSLocalizedString(messageKey, comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString(buttonKey, comment: ""), style: .default, handler: handler))
            self.present(alert, animated: true){}
        })
    }
    
    fileprivate func goToHome(){
        ActivityLoader.shared.hideProgressView()
        DispatchQueue.main.async(execute: { () -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavHomeViewController")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        })
    }

}

extension LoginViewController : DressingSynchroDelegate {
    func dressingSynchro(_ dressingSynchro: DressingSynchro, syncDidFinish isFinish: Bool) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.goToHome()
        })
        
    }
    
    func dressingSynchro(_ dressingSynchro: DressingSynchro, synchingProgressing currentValue: Int, totalNumber: Int) {
        ActivityLoader.shared.setLabel("Synching \(currentValue)/\(totalNumber) clothes")
    }
}

extension LoginViewController {
    fileprivate func login(_ email: String?, password: String?){
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
                                let alert = UIAlertController(title: "Account not validate", message: "Please validate your account! Do you want to send again the email?", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Resend", style: .default, handler: { (action) -> Void in
                                    //Resend Validation Email
                                    LoginService().SendVerificationEmail(login, completion: { (isSuccess, object) -> Void in
                                        print("Email Send");
                                    });
                                }));
                                alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
                                    self.dismiss(animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true){}
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
    
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}

extension LoginViewController : FBSDKLoginButtonDelegate {
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
                                do {
                                    self.userByFB?.picture_data = try Data(contentsOf: URL(string: url)!)
                                } catch {
                                    print("Error") // TODO - Notify User
                                }
                            }
                            let storyboard = UIStoryboard(name: "Register", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "SelectStyleViewController") as! SelectStyleViewController
                            vc.user = self.userByFB
                            self.present(vc, animated: true, completion: nil)
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
}
