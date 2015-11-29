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
    private var isWrong = false
   
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCreateButtonTapped(sender: AnyObject) {
        //Validate Email et go to step 2 choose password if email password
        if let emailTemp = emailText.text {
            if (isValidEmail(emailTemp)){
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        configNavBar()
        emailText.attributedPlaceholder = NSAttributedString(string:"barack.obama@usa.gov",
            attributes:[NSForegroundColorAttributeName: UIColor(red: 255, green: 255, blue: 255, alpha: 0.60),
                NSFontAttributeName: UIFont.italicSystemFontOfSize(15.0)])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emailText.text = email
    }
    
    override func viewDidLayoutSubviews(){
        applyStyleTextView(emailText)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectPassword") {
            if let viewController = segue.destinationViewController as? RegisterPasswordViewController {
                viewController.email = email
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
    
}