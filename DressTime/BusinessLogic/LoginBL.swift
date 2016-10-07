//
//  LoginBL.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

open class LoginBL {
    
    //Update
    open func loginWithSuccess(_ object: JSON){
        let dal = ProfilsDAL()
        let user = User(json: object)
        SharedData.sharedInstance.currentUserId = user.email
        SharedData.sharedInstance.sexe = user.gender
        
        //If profil already exist update
        if dal.fetch(user.email.lowercased()) != nil {
            if let newProfil = dal.update(user) {
                if let id = newProfil.fb_id , !id.isEmpty{
                    do {
                    newProfil.picture = try Data(contentsOf: URL(string: "https://graph.facebook.com/\(id)/picture?width=100&height=100")!)
                    _ = dal.update(newProfil)
                    } catch {
                        print("Error") //TODO : Display error to user
                    }
                }
            }
        } else {
            if let profil = dal.save(user) {
                LoginBL().updateStyle(profil)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(user.email, forKey: "userId")
        defaults.synchronize()
    }
    
    
    func returnUserData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                print(result)
/*                self.email = result.valueForKey("email") as! String
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
                } */
            }
        })
    }
    
    open func loginFacebookWithSuccess(_ object: JSON) -> User{
        let email = object["emails"].arrayValue[0]["value"].stringValue
        let displayName = object["displayName"].stringValue
        
        let user = User(email: email, username: email, displayName: displayName)
        user.fb_id = object["id"].stringValue
        user.fb_token = FBSDKAccessToken.current().tokenString
        user.picture = object["_json"]["picture"]["data"]["url"].stringValue
        user.gender = object["gender"].stringValue == "male" ? "M" : "F"
        user.isVerified = true
        user.tempUnit = "C"
        
        return user
    }
    
    open func logoutWithSuccess(_ user: Profil?){
        let dal = ProfilsDAL()
        var profilOld: Profil?
        if let userTmp = user {
            profilOld = dal.fetch(userTmp.userid!)
        } else {
            profilOld = dal.fetch(SharedData.sharedInstance.currentUserId!)
        }
        
        if let profil = profilOld {
            if (FBSDKAccessToken.current() != nil){
                FBSDKLoginManager().logOut()
                profil.fb_token = ""
            }
            profil.access_token = ""
            profil.refresh_token = ""
            profil.expire_in = 0
            
            _ = dal.update(profil)
        }
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userId")
        defaults.synchronize()

    }
    
    open func mergeProfilWithFacebook(_ user: Profil){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender"])
        
        graphRequest.start { (connection, result, error) in
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                if let data:[String:AnyObject] = result as? [String : AnyObject] {
                    user.fb_id = data["id"] as? String
                    user.fb_token = FBSDKAccessToken.current().tokenString
                    if let picture = data["picture"] as? NSDictionary {
                        if let valueDict : NSDictionary = picture.value(forKey: "data") as? NSDictionary {
                            user.picture_url = valueDict.value(forKey: "url") as? String
                        }
                    }
                    
                    UserService().UpdateUser(user, completion: { (isSuccess, object) -> Void in
                        if (isSuccess){
                            let dal = ProfilsDAL()
                            _ = dal.update(user)
                        }
                    })
                }
                
                
            }

        }
    }
    
    open func unmergeProfilWithFacebook(_ user: Profil, completion: @escaping (_ isSuccess: Bool) -> Void){
        user.fb_id = ""
        user.fb_token = ""
        UserService().UpdateUser(user, completion: { (isSuccess, object) -> Void in
            if (isSuccess){
                let dal = ProfilsDAL()
                _ = dal.update(user)
            }
            completion(isSuccess)
        })
        
    }
    
    open func showLoginPage(_ error: Foundation.Notification){
        /* Display alert and redirect to login page */
        if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window {
            let alert = UIAlertController(title: "No Login title", message: "No Login message", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: { (alertAction) in
                //Go back to login page
                DispatchQueue.main.async(execute: { () -> Void in
                    let rootController:UIViewController = UIStoryboard(name: "Register", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigationController")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window!.makeKeyAndVisible()
                    appDelegate.window!.rootViewController = rootController
                    
                    //self.navigationController?.popToRootViewControllerAnimated(false)
                })
                
            }))
            DispatchQueue.main.async(execute: {
                window!.rootViewController?.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func updateStyle(_ profil: Profil){
        var styles = [String]()
        if profil.styles == nil {
            if let workStyle = profil.atWorkStyle {
                styles.append(workStyle)
                profil.atWorkStyle = nil
            }
            
            if let partyStyle = profil.onPartyStyle , !styles.contains(partyStyle) {
                styles.append(partyStyle)
                profil.onPartyStyle = nil
            }
            
            if let relaxStyle = profil.relaxStyle , !styles.contains(relaxStyle) {
                styles.append(relaxStyle)
                profil.relaxStyle = nil
            }
            
            profil.styles = styles.joined(separator: ",")
            //TODO Save new styles on back-end
            UserService().UpdateUser(profil, completion: { (isSuccess, object) -> Void in
                let profilDal = ProfilsDAL()
                _ = profilDal.update(profil)
            })
        }
    }
}
