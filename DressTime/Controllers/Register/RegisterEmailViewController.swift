//
//  RegisterEmailViewController.swift
//  DressTime
//
//  Created by Fab on 22/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterEmailViewController: DTViewController {

    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var onShowPasswordTap: UIButton!
    @IBOutlet weak var fbButtonContainer: UIView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    private var email:String = ""
    private var isWrong = false
    
    private var user: User?
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCreateButtonTapped(sender: AnyObject) {
        //If Login with Facebook -> go directly to step 3
        if (FBSDKAccessToken.currentAccessToken() != nil){
            self.performSegueWithIdentifier("selectStyle", sender: self)
            return
        }
        
        //Validate Email et go to step 2 choose password if email password
        if let emailTemp = emailText.text {
            if (isValidEmail(emailTemp)){
                self.user = User(email: emailTemp, username: nil, displayName: nil)
                email = emailTemp
                isWrong = false
                self.performSegueWithIdentifier("selectPassword", sender: self)
            } else {
                //Show error
                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterEmail"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        configNavBar()
        emailText.attributedPlaceholder = NSAttributedString(string:"barack.obama@usa.gov",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 255, green: 255, blue: 255, alpha: 0.60),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(15.0)])
        
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil){
            returnUserData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emailText.text = email
        //self.returnUserData()
    }
    
    override func viewDidLayoutSubviews(){
        applyStyleTextView(emailText)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectStyle") {
            if let viewController = segue.destinationViewController as? RegisterStyleViewController {
                //viewController.email = email
                viewController.user = self.user
            }
        } else if (segue.identifier == "selectPassword"){
            if let viewController = segue.destinationViewController as? RegisterPasswordViewController {
                //viewController.email = email
                viewController.user = self.user
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func configNavBar(){
        let bar:UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        bar.shadowImage = UIImage()
        bar.tintColor = UIColor.whiteColor()
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        bar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func applyStyleTextView(textField: UITextField){
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 0.5, textField.frame.width + 25, 0.5)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func returnUserData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                print(result)
                self.email = result.valueForKey("email") as! String
                self.emailText.text = self.email
                self.user = User(email: self.email, username: self.email, displayName: result.valueForKey("name") as? String)
                self.user!.fb_id = result.valueForKey("id") as? String
                self.user!.fb_token = FBSDKAccessToken.currentAccessToken().tokenString
                
                if let gender = result.valueForKey("gender") as? String {
                    self.user!.gender = gender == "male" ? "M" : "F"
                }
                if let picture = result.valueForKey("picture") as? NSDictionary {
                    if let valueDict : NSDictionary = picture.valueForKey("data") as? NSDictionary {
                        self.user!.picture = valueDict.valueForKey("url") as? String
                    }
                }
            }
        })
    }
   
}

extension RegisterEmailViewController : FBSDKLoginButtonDelegate {
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
                print(FBSDKAccessToken.currentAccessToken())
                // Do work
                
                //If login with FB, get all Data
                //Pre-filling all data that I can do
                //Save fb specific data to an object fb into user object
                returnUserData()
                
                //Modify WebService call to pass access_token = , if FBSDKAccessToken.currentAccessToken() not nil
                
                //Otherwise use a usual via bearer
                
                //How to manage FB refresh token....
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
}