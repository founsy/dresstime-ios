//
//  SelectStyleViewController.swift
//  DressTime
//
//  Created by Fab on 7/24/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Mixpanel

enum Style : String {
    case CasualChic = "casual"
    case Fashion = "fashion"
    case Sportwear = "sportwear"
    case Business = "business"
}

class SelectStyleViewController: DTViewController {
    
    fileprivate var selectedStyle = [String]()
    fileprivate var confirmationView: ConfirmSave?
    
    var currentUserId: String?
    var user: User?
    
    @IBOutlet weak var fashionbutton: UIButton!
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var sportWearButton: UIButton!
    @IBOutlet weak var casualChicButton: UIButton!
    @IBOutlet weak var validationButton: UIButton!
    @IBOutlet weak var selectStyleLabel: UILabel!
    @IBOutlet weak var fashionLabel: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var sportwearLabel: UILabel!
    @IBOutlet weak var casualChicLabel: UILabel!
    
    
    @IBAction func buttonsStyle(_ sender: AnyObject) {
        if (sender === fashionbutton){
            fashionbutton.isSelected = !fashionbutton.isSelected
            if (!selectedStyle.contains(Style.Fashion.rawValue)){
                selectedStyle.append(Style.Fashion.rawValue)
            } else {
                if let index = selectedStyle.index(of: Style.Fashion.rawValue) {
                    selectedStyle.remove(at: index)
                }

            }
        } else if (sender === businessButton){
            businessButton.isSelected = !businessButton.isSelected
            
            if (!selectedStyle.contains(Style.Business.rawValue)){
                selectedStyle.append(Style.Business.rawValue)
            } else {
                if let index = selectedStyle.index(of: Style.Business.rawValue) {
                    selectedStyle.remove(at: index)
                }
                
            }
        } else if (sender === sportWearButton){
            sportWearButton.isSelected = !sportWearButton.isSelected
            
            if (!selectedStyle.contains(Style.Sportwear.rawValue)){
                selectedStyle.append(Style.Sportwear.rawValue)
            } else {
                if let index = selectedStyle.index(of: Style.Sportwear.rawValue) {
                    selectedStyle.remove(at: index)
                }
                
            }
        } else if (sender === casualChicButton){
            casualChicButton.isSelected = !casualChicButton.isSelected
            
            if (!selectedStyle.contains(Style.CasualChic.rawValue)){
                selectedStyle.append(Style.CasualChic.rawValue)
            } else {
                if let index = selectedStyle.index(of: Style.CasualChic.rawValue) {
                    selectedStyle.remove(at: index)
                }
            }
        }
        validationButton.isEnabled = !(selectedStyle.count == 0) //TODO - Change color when button is disabled
        if (validationButton.isEnabled) {
            validationButton.backgroundColor = UIColor.dressTimeRed()
        } else {
            validationButton.backgroundColor = UIColor.dressTimeRedDisabled()
        }
    }
    
    @IBAction func onValidatationTapped(_ sender: AnyObject) {
        //Update Current User
        if let userId = currentUserId {
            modifyUser(userId)
        } else { //Create new User
            createUser()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterStyle"
        self.navigationController?.isNavigationBarHidden = false
        
        if let userId = currentUserId {
            let dal = ProfilsDAL()
            if let profil = dal.fetch(userId) {
                if let stylesStr = profil.styles {
                    self.selectedStyle = stylesStr.components(separatedBy: ",")
                    for item in self.selectedStyle {
                        switch(item) {
                        case Style.Business.rawValue:
                            businessButton.isSelected = true
                        case Style.CasualChic.rawValue:
                            casualChicButton.isSelected = true
                        case Style.Fashion.rawValue:
                            fashionbutton.isSelected = true
                        case Style.Sportwear.rawValue:
                            sportWearButton.isSelected = true
                        default:
                            print("No style")
                        }
                    }
                }
                
            } else {
              //  validationButton.enabled = false
            }
        }
        
        self.createConfirmationView()
        
    }
    
    fileprivate func setLocalization(){
        validationButton.setTitle(NSLocalizedString("styleSelectionValidationButton", comment: ""), for: UIControlState())
        selectStyleLabel.text = NSLocalizedString("styleSelectionStyleLabel", comment: "").uppercased()
        fashionLabel.text = NSLocalizedString("styleSelectionFashionLabel", comment: "")
        businessLabel.text = NSLocalizedString("styleSelectionBusinessLabel", comment: "")
        sportwearLabel.text = NSLocalizedString("styleSelectionSportwearLabel", comment: "")
        casualChicLabel.text = NSLocalizedString("styleSelectionCasualChicLabel", comment: "")
    }
    
    fileprivate func createConfirmationView(){
        self.confirmationView = Bundle.main.loadNibNamed("ConfirmSave", owner: self, options: nil)?[0] as? ConfirmSave
        self.confirmationView!.frame = CGRect(x: UIScreen.main.bounds.size.width/2.0 - 50, y: UIScreen.main.bounds.size.height/2.0 - 50, width: 100, height: 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
        
        self.view.addSubview(self.confirmationView!)
    }
    
    fileprivate func createUser(){
        if let newUser = self.user {
            let dal = ProfilsDAL()
            newUser.styles = self.selectedStyle.joined(separator: ",")            
            
            if let profil = dal.save(newUser) {
                let dressTimeClient = DressTimeClient()
                dressTimeClient.createUserWithCompletion(profil, password: newUser.password, withCompletion: { (result) in
                    switch result {
                    case .success(_):
                        if (FBSDKAccessToken.current() == nil){
                            self.loginSuccess(profil, password: newUser.password!)
                        } else {
                            let defaults = UserDefaults.standard
                            defaults.set(profil.userid, forKey: "userId")
                            defaults.synchronize()
                        }
                        SharedData.sharedInstance.currentUserId = profil.userid
                        SharedData.sharedInstance.sexe = profil.gender
                        
                        let mixpanel = Mixpanel.sharedInstance()
                        mixpanel.people.set(["$name" : profil.lastName!, "firstname": profil.firstName!, "$email" : profil.email!, "Styles": profil.styles!,"Notification" : NotificationTime.morning.rawValue])
                        
                        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                            self.confirmationView?.alpha = 1
                            self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                            }, completion: { (isFinish) -> Void in
                                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                    self.confirmationView?.alpha = 0
                                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                                    }, completion: { (finish) -> Void in
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavHomeViewController")
                                            appDelegate.window?.rootViewController = initialViewController
                                            appDelegate.window?.makeKeyAndVisible()
                                        })
                                })
                        })
                    case .failure(let error):
                        //TODO: Manage Error from Server
                        print("\(#function) Error: \(error)")
                        switch error {
                        case DressTimeError.duplicateAccountError(_):
                            NotificationCenter.default.post(name: Notifications.Error.CreateAccount_Email_Duplicate, object: nil)
                        default:
                             NotificationCenter.default.post(name: Notifications.Error.CreateAccount, object: nil)
                        }
                        /*if (object["code"].numberValue == 11000){
                            //TODO - Duplication Key (email)
                            NotificationCenter.default.post(name: Notifications.Error.CreateAccount_Email_Duplicate, object: nil)
                            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.Error.CreateAccount_Email_Duplicate), object: nil)
                        } else if (object["name"].stringValue == "ValidationError") {
                            NotificationCenter.default.post(name: Notifications.Error.CreateAccount_Style_Required, object: nil)
                        } else {
                         
                        }
                        return */
                    }
                })
            }
        }
    }
    
    fileprivate func modifyUser(_ userId: String){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userId) {
            profil.styles = self.selectedStyle.joined(separator: ",")
            
            let newProfil = dal.update(profil)
            let dressTimeClient = DressTimeClient()
            dressTimeClient.updateUserWithCompletion(newProfil!, withCompletion: { (result) in
                switch result {
                case .success(_):
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                    self.view.bringSubview(toFront: self.confirmationView!)
                    
                    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.confirmationView?.alpha = 1
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                        }, completion: { (isFinish) -> Void in
                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                self.confirmationView?.alpha = 0
                                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                                }, completion: { (finish) -> Void in
                                    _ = self.navigationController?.popViewController(animated: true)
                            })
                    })
                case .failure(let error):
                    //TODO: Error Management
                    print("\(#function) Error: \(error)")
                }
            })
        }
    }
    
    fileprivate func loginSuccess(_ profil: Profil, password: String){
        let dressTimeClient = DressTimeClient()
        dressTimeClient.fetchLoginWithCompletion(with: profil.email!, password: password) { (result) in
            switch result {
            case .success(let json):
                let loginBL = LoginBL();
                loginBL.loginWithSuccess(json)
            case .failure(let _):
                ActivityLoader.shared.hideProgressView()
                //TODO: Use Notification Center to display error
                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .default) { _ in })
                self.present(alert, animated: true){}
            }
        }
    }
}
