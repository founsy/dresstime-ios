//
//  RegisterPasswordViewController.swift
//  DressTime
//
//  Created by Fab on 24/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterPasswordViewController: DTViewController {
    
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var onShowPasswordTap: UIButton!
    
    var email:String = ""
    private var password: String = ""
    
    var user: User?
    
    private var isEmailStep = true
    
    @IBAction func onHidePasswordTapped(sender: AnyObject) {
        if (passwordText.secureTextEntry) {
            passwordText.secureTextEntry = false
            hidePasswordButton.selected = false
        } else {
            passwordText.secureTextEntry = true
            hidePasswordButton.selected = true
        }
    }
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCreateButtonTapped(sender: AnyObject) {
        //Validate Email et go to step 2 choose password if email password
        if let passwordTemp = passwordText.text {
            if let _ = self.user {
                self.user!.password = passwordTemp
            }
            password = passwordTemp
            self.performSegueWithIdentifier("selectSexe", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterPassword"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        passwordText.attributedPlaceholder = NSAttributedString(string:"MySecurePassword",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 255, green: 255, blue: 255, alpha: 0.60),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(15.0)])
    }
    
    override func viewDidLayoutSubviews(){
        applyStyleTextView(passwordText)
        createAccountButton.layer.borderColor = UIColor.whiteColor().CGColor
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.cornerRadius = 10.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectSexe") {
            if let viewController = segue.destinationViewController as? RegisterSexeViewController {
                viewController.user = self.user
                viewController.email = email
                viewController.password = password
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
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
}