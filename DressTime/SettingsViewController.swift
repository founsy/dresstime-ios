//
//  SettingsViewController.swift
//  DressTime
//
//  Created by Fab on 01/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit




class SettingsViewController: UIViewController {
    private var user: Profil?
    private var tableViewController: SettingsTableViewController?
   
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        if let userSaving = self.user {
            if let vc = tableViewController {
                if (vc.menSelected){
                    userSaving.gender = "M"
                } else {
                    userSaving.gender = "F"
                }
                //Update SharedData
                SharedData.sharedInstance.sexe = userSaving.gender
                
                if (vc.temperatureField.selectedSegmentIndex == 0){
                    userSaving.temp_unit = "C"
                } else {
                    userSaving.temp_unit = "F"
                }
                
                if let email = vc.emailField.text {
                    userSaving.email = email
                }
                if let name = vc.nameField.text {
                    userSaving.name = name
                }
                let profilDal = ProfilsDAL()
                profilDal.update(userSaving)
            }
            
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            LoginService().Logout(user.access_token!, completion: { (isSuccess, object) -> Void in
                let dal = ProfilsDAL()
                let profilOld = dal.fetch(user.userid!)
                if let profil = profilOld {
                    profil.access_token = ""
                    profil.refresh_token = ""
                    profil.expire_in = 0
                    dal.update(profil)
                }
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    //Go back to login window
                    let rootController:UIViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController")
                    self.presentViewController(rootController, animated: true, completion: nil)
                })
            })
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            changeBackground(self.user!.gender!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Remove Title of Back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: nil, action: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "settingTableView"){
            tableViewController = segue.destinationViewController as? SettingsTableViewController
            tableViewController?.delegate = self
        }
    }
    
    private func changeBackground(sex: String){
        dispatch_async(dispatch_get_main_queue(),  { () -> Void in
            if (sex == "M"){
                self.backgroundView.image = UIImage(named: "ProfilsSettingBgdMen")
            } else {
                self.backgroundView.image = UIImage(named: "ProfilsSettingBgdWomen")
            }
        })
    }
}

extension SettingsViewController: SettingsTableViewControllerDelegate {
    func onSexeChange(sexe: String){
        changeBackground(sexe)
    }
}

