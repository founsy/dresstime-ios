//
//  RegisterEmailViewController.swift
//  DressTime
//
//  Created by Fab on 22/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterEmailViewController: UIViewController {

    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var onShowPasswordTap: UIButton!
    
    private var email:String = ""
    private var password: String = ""
    
    private var isEmailStep = true
    
    @IBAction func onHidePasswordTapped(sender: AnyObject) {
        if (emailText.secureTextEntry) {
            emailText.secureTextEntry = false
            hidePasswordButton.setImage(UIImage(named: "eyesclosdIcon"), forState: .Normal)
        } else {
            emailText.secureTextEntry = true
            hidePasswordButton.setImage(UIImage(named: "eyesopen"), forState: .Normal)
        }
    }
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        if (isEmailStep){
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            showEmail()
            isEmailStep = true
        }
    }
    
    @IBAction func onCreateButtonTapped(sender: AnyObject) {
        //Validate Email et go to step 2 choose password if email password
        if (email == ""){
            if let emailTemp = emailText.text {
                if (isValidEmail(emailTemp) && emailTemp != "barack.obama@usa.gov"){
                    email = emailTemp
                    isEmailStep = false
                    showPassword()
                } else {
                    //Show error
                }
            }
        } else if (email != "") {
            if let passwordTemp = emailText.text {
                if (passwordTemp != "MySecurePassword2015"){
                    password = passwordTemp
                    self.performSegueWithIdentifier("selectSexe", sender: self)
                }
            }
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showEmail()
    }
    
    override func viewDidLayoutSubviews(){
        applyStyleTextView(emailText)
        createAccountButton.layer.borderColor = UIColor.whiteColor().CGColor
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.cornerRadius = 10.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectSexe") {
            if let viewController = segue.destinationViewController as? RegisterSexeViewController {
                viewController.email = email
                viewController.password = password
            }
        }
    }
    
    private func showPassword(){
        textLabel.text = "PASSWORD"
        emailText.text = "MySecurePassword2015"
        hidePasswordButton.hidden = false
        emailText.secureTextEntry = true
        hidePasswordButton.setImage(UIImage(named: "eyesopen"), forState: .Normal)
        view.endEditing(true)
    }
    
    private func showEmail(){
        textLabel.text = "YOUR EMAIL"
        emailText.text = email == "" ? "barack.obama@usa.gov" : email
        email = ""
        password = ""
        hidePasswordButton.hidden = true
        emailText.secureTextEntry = false
        view.endEditing(true)
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
}