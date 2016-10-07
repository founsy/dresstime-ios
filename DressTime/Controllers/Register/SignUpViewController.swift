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
    fileprivate var nameView : UIView?
    fileprivate var emailView: UIView?
    fileprivate var passwordView: UIView?
    fileprivate var firstNameField : DTTextField?
    fileprivate var lastNameField : DTTextField?
    fileprivate var emailField: DTTextField?
    fileprivate var passwordField: DTTextField?
    fileprivate var step = 0
    
    fileprivate var alreadyLayout = false
    fileprivate var user: User?
    
    @IBAction func onNextTapped(_ sender: AnyObject) {
        let damping:CGFloat = 0.9
        let velocity:CGFloat = 5.0
        
        //FirstName - LastName field
        if (step == 0) {
            if let firstField = self.firstNameField, let nameField = self.lastNameField {
                if let firstName = firstField.text, let lastName = nameField.text {
                    if !((firstName.isEmpty) && (lastName.isEmpty)) {
                        user = User(email: "", username: "", displayName: firstName.lowercased())
                        user!.lastName = lastName.lowercased()
                        user!.firstName = firstName.lowercased()
                        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.curveEaseIn, animations: {
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
                        self.user!.email = email.lowercased()
                        self.user!.username = email.lowercased()
                        
                        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.curveEaseIn, animations: {
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
                        self.performSegue(withIdentifier: "showSexe", sender: self)
                    }
                }
            }
        }
    
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.dressTimeRed()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.dressTimeRed()]
        
        nextButton.layer.cornerRadius = 3.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setLocalization()

    }
    
    override func viewDidLayoutSubviews(){
        if (!alreadyLayout){
            self.nameView!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.containerView.frame.height)
            self.emailView!.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: self.containerView.frame.height)
            self.passwordView!.frame = CGRect(x: UIScreen.main.bounds.width*2, y: 0, width: UIScreen.main.bounds.width, height: self.containerView.frame.height)
            alreadyLayout = true
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createNameView()
        createEmailView()
        createPasswordView()
        step = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectStyle") {
            if let viewController = segue.destination as? SelectStyleViewController {
                viewController.user = self.user
            }
        } else if (segue.identifier == "showSexe") {
            if let viewController = segue.destination as? RegisterSexeViewController {
                viewController.user = self.user
            }
        }
    }

    
    func keyboardWillShow(_ notification: Foundation.Notification) {
     
        if let _ = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let offset = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            
            let keyboardY = offset.origin.y - 42 //Suggestion
            
            let buttonY = self.nextButton.frame.origin.y + self.nextButton.frame.height

            if (!(keyboardY - buttonY > 10)) {
                viewKeyboardHeight.constant = fabs(keyboardY - buttonY) + self.nextButton.frame.height
                topConstrainte.constant = -(fabs(keyboardY - buttonY) + (self.nextButton.frame.height/2.0))
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            
        }
    }
    
    func keyboardWillHide(_ notification: Foundation.Notification) {
        if let _ = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            viewKeyboardHeight.constant = 0
            topConstrainte.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })

        }
    }
    
    fileprivate func setLocalization(){
        nextButton.setTitle(NSLocalizedString("signupNextButton", comment: "Next"), for: UIControlState())
    }
    
    
    fileprivate func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    fileprivate func createNameView(){
       
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
    
    fileprivate func createEmailView(){
        
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
    
    fileprivate func createPasswordView(){
        
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
    
    fileprivate func createLabel(_ text : String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(red: 240/255, green: 81/255, blue: 85/255, alpha: 1.0)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    fileprivate func createStackView(_ subViews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subViews)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    fileprivate func createField(_ placeHolder: String, leftImage: UIImage?) -> DTTextField{
        let field = DTTextField()
        field.placeholder = placeHolder
        if let img = leftImage {
            field.leftImage = img
        }
        field.textAlignment = .center
        return field
    }
    
    fileprivate func addConstraintes(_ containerView: UIView, stackView: UIStackView, label: UILabel){
        let viewsDictionary = ["stackView":stackView, "label":label]
        
        let label_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let label_V = NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-15-[stackView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[stackView]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[stackView]-10-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        
        
        containerView.addConstraints(label_H)
        containerView.addConstraints(label_V)
        containerView.addConstraints(stackView_H)
        containerView.addConstraints(stackView_V)
    }
}
