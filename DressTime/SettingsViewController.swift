//
//  SettingsViewController.swift
//  DressTime
//
//  Created by Fab on 04/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation


import UIKit

class SettingsViewController : UIViewController {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var temperature: UISegmentedControl!
    @IBOutlet weak var atWorkView: UIView!
    @IBOutlet weak var onPartyView: UIView!
    @IBOutlet weak var relaxView: UIView!
    
    @IBAction func onLogout(sender: AnyObject) {
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            let jsonObject: [String: AnyObject] = [
                "access_token": user.access_token
            ]
            
            LoginService.logoutMethod(jsonObject, getCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
                //if (succeeded){
                    let dal = ProfilsDAL()
                    let profilOld = dal.fetch(user.userid)
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
                //}
            })
        }

    }
    
    @IBAction func onSave(sender: AnyObject) {
        
        if let userSaving = self.user {
            
            if (gender.selectedSegmentIndex == 0){
                userSaving.gender = "M"
            } else {
                userSaving.gender = "F"
            }
            
            if (temperature.selectedSegmentIndex == 0){
                userSaving.temp_unit = "C"
            } else {
                userSaving.temp_unit = "F"
            }
            let profilDal = ProfilsDAL()
            profilDal.update(userSaving)
            
        }
        
    }
    
    var user: Profil?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilDal = ProfilsDAL()
        
        if let user = profilDal.fetch(SharedData.sharedInstance.currentUserId!) {
            self.user = user
            nameText.text = user.userid
            
            if (user.gender == "M"){
                gender.selectedSegmentIndex = 0
            } else {
                gender.selectedSegmentIndex = 1
            }
            
            if (user.temp_unit == "C") {
                temperature.selectedSegmentIndex = 0
            } else {
                temperature.selectedSegmentIndex = 1
            }
        }
        atWorkView.layer.cornerRadius = 25
        onPartyView.layer.cornerRadius = 25
        relaxView.layer.cornerRadius = 25
        
    }
}