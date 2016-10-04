//
//  SignUpViewController.swift
//  login
//
//  Created by Fabian Langlet on 7/20/16.
//  Copyright © 2016 Fabian Langlet. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewController : UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topConstrainteLogo: NSLayoutConstraint!
    @IBOutlet weak var viewKeyboardHeight: NSLayoutConstraint!
    @IBOutlet weak var topConstrainte: NSLayoutConstraint!
    private var nameView : UIView?
    private var emailView: UIView?
    private var passwordView: UIView?
    private var firstNameField : DTTextField?
    private var lastNameField : DTTextField?
    private var emailField: DTTextField?
    private var passwordField: DTTextField?
    private var step = 0
    
    private var alreadyLayout = false
    private var user: User?
    
    @IBAction func onNextTapped(sender: AnyObject) {
        let damping:CGFloat = 0.9
        let velocity:CGFloat = 5.0
        
        //FirstName - LastName field
        if (step == 0) {
            if let firstField = self.firstNameField, let nameField = self.lastNameField {
                if let firstName = firstField.text, let lastName = nameField.text {
                    if !((firstName.isEmpty) && (lastName.isEmpty)) {
                        user = User(email: "", username: "", displayName: firstName.lowercaseString)
                        user!.lastName = lastName.lowercaseString
                        user!.firstName = firstName.lowercaseString
                        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.nameView!.frame = CGRect(x: -self.nameView!.frame.width, y: self.nameView!.frame.origin.y, width: self.nameView!.frame.width, height: self.nameView!.frame.height)
                            self.emailView!.frame = CGRect(x: 0, y: self.emailView!.frame.origin.y, width:  self.emailView!.frame.width, height:  self.emailView!.frame.height)
                            self.passwordView!.frame = CGRect(x: self.passwordView!.frame.width, y: self.passwordView!.frame.origin.y, width:  self.passwordView!.frame.width, height:  self.passwordView!.frame.height)
                            }, completion: { (value) in
                                self.step = 1
                        })
                    }
                }
            }
            
        } else if (step == 1) { //Email field
            if let emailField = self.emailField {
                if let email = emailField.text {
                    if (!(email.isEmpty) && isValidEmail(email)) {
                        self.user!.email = email.lowercaseString
                        self.user!.username = email.lowercaseString
                        
                        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                            self.nameView!.frame = CGRect(x: -self.nameView!.frame.width*2, y: self.nameView!.frame.origin.y, width: self.nameView!.frame.width, height: self.nameView!.frame.height)
                            self.emailView!.frame = CGRect(x: -self.nameView!.frame.width, y: self.emailView!.frame.origin.y, width:  self.emailView!.frame.width, height:  self.emailView!.frame.height)
                            self.passwordView!.frame = CGRect(x: 0, y: self.passwordView!.frame.origin.y, width:  self.passwordView!.frame.width, height:  self.passwordView!.frame.height)
                            }, completion: { (value) in
                                self.step = 2
                        })
                    }
                }
            }
        } else if (step == 2) { //Password field
            if let passwordField = self.passwordField {
                if let password = passwordField.text {
                    if (!(password.isEmpty)) {
                        self.user!.password = password
                        self.performSegueWithIdentifier("showSexe", sender: self)
                    }
                }
            }
        }
    
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        
        nextButton.layer.cornerRadius = 3.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        setLocalization()

    }
    
    override func viewDidLayoutSubviews(){
        if (!alreadyLayout){
            self.nameView!.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.containerView.frame.height)
            self.emailView!.frame = CGRect(x: UIScreen.mainScreen().bounds.width, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.containerView.frame.height)
            self.passwordView!.frame = CGRect(x: UIScreen.mainScreen().bounds.width*2, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.containerView.frame.height)
            alreadyLayout = true
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createNameView()
        createEmailView()
        createPasswordView()
        step = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectStyle") {
            if let viewController = segue.destinationViewController as? SelectStyleViewController {
                viewController.user = self.user
            }
        } else if (segue.identifier == "showSexe") {
            if let viewController = segue.destinationViewController as? RegisterSexeViewController {
                viewController.user = self.user
            }
        }
    }

    
    func keyboardWillShow(notification: NSNotification) {
     
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(),
            let offset = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(){
            
            let keyboardY = offset.origin.y - 42 //Suggestion
            
            let buttonY = self.nextButton.frame.origin.y + self.nextButton.frame.height

            if (!(keyboardY - buttonY > 10)) {
                viewKeyboardHeight.constant = fabs(keyboardY - buttonY) + self.nextButton.frame.height
                topConstrainte.constant = -(fabs(keyboardY - buttonY) + (self.nextButton.frame.height/2.0))
                UIView.animateWithDuration(0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            viewKeyboardHeight.constant = 0
            topConstrainte.constant = 0
            UIView.animateWithDuration(0.3, animations: {
                self.view.layoutIfNeeded()
            })

        }
    }
    
    private func setLocalization(){
        nextButton.setTitle(NSLocalizedString("signupNextButton", comment: "Next"), forState: .Normal)
    }
    
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func createNameView(){
       
        let label = createLabel( NSLocalizedString("signupCreateNameLabel", comment: "The future awesome wardrobe belongs to..."))
   
        self.firstNameField = createField("Barack", leftImage: UIImage(named: "LoginProfileIcon"))
        self.firstNameField!.VertiSeparator = true
        self.firstNameField!.LeftRadius = 8.0
        
        self.lastNameField = createField("Obama", leftImage: nil)
        self.lastNameField!.RightRadius = 8.0
        
        let stackView =  createStackView([self.firstNameField!, self.lastNameField!])
        
        self.nameView = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        self.nameView!.addSubview(label)
        self.nameView!.addSubview(stackView)

        //autolayout the stack view - pin 30 up 20 left 20 right 30 down
        addConstraintes(self.nameView!, stackView: stackView, label: label)
        
        self.containerView.addSubview(self.nameView!)
    }
    
    private func createEmailView(){
        
        let label = createLabel(NSLocalizedString("signupCreateEmailLabel", comment: "You will receive you amazing suggestions..."))
        
        self.emailField = createField("barackobama@whitehouse.gov", leftImage: UIImage(named: "LoginMailIcon"))
        self.emailField!.AllRadius = 8.0
        
        let stackView =  createStackView([self.emailField!])

        self.emailView = UIView(frame: CGRect(x: self.containerView.frame.width, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        self.emailView!.addSubview(label)
        self.emailView!.addSubview(stackView)
        
        //autolayout the stack view - pin 30 up 20 left 20 right 30 down
        addConstraintes(self.emailView!, stackView: stackView, label: label)
        
        self.containerView.addSubview(self.emailView!)
    }
    
    private func createPasswordView(){
        
        let label = createLabel(NSLocalizedString("signupCreatePasswordLabel", comment: "Finally in order to secure your wardrobe..."))

        self.passwordField = createField("MyAmazingPassword2016", leftImage: UIImage(named: "LoginPasswordIcon"))
        self.passwordField!.isPassword = true
        self.passwordField!.AllRadius = 8.0
        
        let stackView =  createStackView([self.passwordField!])
        
        self.passwordView = UIView(frame: CGRect(x: self.containerView.frame.width * 2, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        self.passwordView!.addSubview(label)
        self.passwordView!.addSubview(stackView)
        
        //autolayout the stack view - pin 30 up 20 left 20 right 30 down
        addConstraintes(self.passwordView!, stackView: stackView, label: label)
        
        self.containerView.addSubview(self.passwordView!)
    }
    
    private func createLabel(text : String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(red: 240/255, green: 81/255, blue: 85/255, alpha: 1.0)
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    private func createStackView(subViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subViews)
        stackView.axis = .Horizontal
        stackView.distribution = .FillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    private func createField(placeHolder: String, leftImage: UIImage?) -> DTTextField{
        let field = DTTextField()
        field.placeholder = placeHolder
        if let img = leftImage {
            field.leftImage = img
        }
        field.textAlignment = .Center
        return field
    }
    
    private func addConstraintes(containerView: UIView, stackView: UIStackView, label: UILabel){
        let viewsDictionary = ["stackView":stackView, "label":label]
        
        let label_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let label_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-15-[stackView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        let stackView_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[stackView]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        
        
        containerView.addConstraints(label_H)
        containerView.addConstraints(label_V)
        containerView.addConstraints(stackView_H)
        containerView.addConstraints(stackView_V)
    }
}