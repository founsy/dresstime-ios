//
//  LoginViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class LoginViewController: UIDTViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func onClickLoginBtn(sender: AnyObject) {
        if let login = loginText.text {
            if let password = passwordText.text {
                view.endEditing(true)
                ActivityLoader.shared.showProgressView(self.view)
                LoginService().Login(login, password: password) { (isSuccess, object) -> Void in
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
                        } else {
                            let pro = dal.save(object["user"]["username"].string!, email: object["user"]["email"].string!, access_token:  object["access_token"].string!, refresh_token: object["refresh_token"].string!, expire_in: object["expires_in"].int!, name: object["user"]["displayName"].string!, gender: object["user"]["gender"].string!, temp_unit: object["user"]["tempUnit"].string!);
                            
                            pro.atWorkStyle = object["user"]["atWorkStyle"].string
                            pro.onPartyStyle = object["user"]["onPartyStyle"].string
                            pro.relaxStyle = object["user"]["relaxStyle"].string
                            dal.update(pro)
                            
                            SharedData.sharedInstance.currentUserId = pro.userid
                            SharedData.sharedInstance.sexe = pro.gender
                        }
                        
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
                        let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                        self.presentViewController(alert, animated: true){}
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
