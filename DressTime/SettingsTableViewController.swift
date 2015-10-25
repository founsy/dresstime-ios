//
//  NewSettingsTableViewController.swift
//  DressTime
//
//  Created by Fab on 11/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsTableViewControllerDelegate {
    func onSexeChange(sexe: String)
}

class SettingsTableViewController: UITableViewController {
    
    var user: Profil?
    var delegate: SettingsTableViewControllerDelegate?
    
    
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var temperatureField: UISegmentedControl!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    
    var menSelected = true
    
    @IBAction func onGenderSelected(sender: AnyObject) {
        self.menSelected = !self.menSelected
        createBorderButton(menButton, isSelected: self.menSelected)
        createBorderButton(womenButton, isSelected: !self.menSelected)
        if let del = delegate {
            var sexe = "F"
            if (self.menSelected){
                sexe = "M"
            }
            del.onSexeChange(sexe)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            nameField.text = user.name
            emailField.text = user.email
            if (user.temp_unit == "C"){
                temperatureField.selectedSegmentIndex = 0
            } else {
                 temperatureField.selectedSegmentIndex = 1
            }
            self.menSelected = (user.gender == "M")
        }
        currentPasswordField.secureTextEntry = true
        currentPasswordField.text = "passwordDressTime"
        currentPasswordField.clearsOnBeginEditing = true
        newPasswordField.secureTextEntry = true
        
        nameField.delegate = self
        emailField.delegate = self
        currentPasswordField.delegate = self
        newPasswordField.delegate = self
        
        createBorderButton(menButton, isSelected: self.menSelected)
        createBorderButton(womenButton, isSelected: !self.menSelected)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidLayoutSubviews(){
        applyStyleTextView(nameField)
        applyStyleTextView(emailField)
        applyStyleTextView(currentPasswordField)
        applyStyleTextView(newPasswordField)

    }
    
    private func applyStyleTextView(textField: UITextField){
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 1, textField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        textField.borderStyle = UITextBorderStyle.None
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    private func createBorderButton(btn: UIButton, isSelected: Bool){
        var height:CGFloat?
        var color: UIColor?
        if (isSelected){
            height = 4.0
            color = UIColor(red: 235/255, green: 175/255, blue: 73/255, alpha: 1.0)
        } else {
            height = 3.0
            color = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)

        }
        
        let lineView = UIView(frame: CGRectMake(0, btn.frame.size.height - height!, btn.frame.size.width, height!))
        lineView.backgroundColor = color!
        for var subView in btn.subviews {
            if (!subView.isKindOfClass(UILabel)){
                subView.removeFromSuperview()
            }
        }
        
        btn.addSubview(lineView)
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        return true
    }
}
