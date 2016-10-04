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

public class LoginBL {
    
    //Update
    public func loginWithSuccess(object: JSON){
        let dal = ProfilsDAL()
        let user = User(json: object)
        SharedData.sharedInstance.currentUserId = user.email
        SharedData.sharedInstance.sexe = user.gender
        
        //If profil already exist update
        if let profil = dal.fetch(user.email.lowercaseString) {
            if let newProfil = dal.update(user) {
                if let id = newProfil.fb_id where !id.isEmpty{
                    newProfil.picture = NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(id)/picture?width=100&height=100")!)
                    dal.update(newProfil)
                }
            }
        } else {
            if let profil = dal.save(user) {
                LoginBL().updateStyle(profil)
            }
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(user.email, forKey: "userId")
        defaults.synchronize()
    }
    
    
    func returnUserData(){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
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
    
    public func loginFacebookWithSuccess(object: JSON) -> User{
        let email = object["emails"].arrayValue[0]["value"].stringValue
        let displayName = object["displayName"].stringValue
        
        let user = User(email: email, username: email, displayName: displayName)
        user.fb_id = object["id"].stringValue
        user.fb_token = FBSDKAccessToken.currentAccessToken().tokenString
        user.picture = object["_json"]["picture"]["data"]["url"].stringValue
        user.gender = object["gender"].stringValue == "male" ? "M" : "F"
        user.isVerified = true
        user.tempUnit = "C"
        
        return user
    }
    
    public func logoutWithSuccess(user: Profil?){
        let dal = ProfilsDAL()
        var profilOld: Profil?
        if let userTmp = user {
            profilOld = dal.fetch(userTmp.userid!)
        } else {
            profilOld = dal.fetch(SharedData.sharedInstance.currentUserId!)
        }
        
        if let profil = profilOld {
            if (FBSDKAccessToken.currentAccessToken() != nil){
                FBSDKLoginManager().logOut()
                profil.fb_token = ""
            }
            profil.access_token = ""
            profil.refresh_token = ""
            profil.expire_in = 0
            
            dal.update(profil)
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("userId")
        defaults.synchronize()

    }
    
    public func mergeProfilWithFacebook(user: Profil){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            }
            else {
                user.fb_id = result.valueForKey("id") as? String
                user.fb_token = FBSDKAccessToken.currentAccessToken().tokenString
                if let picture = result.valueForKey("picture") as? NSDictionary {
                    if let valueDict : NSDictionary = picture.valueForKey("data") as? NSDictionary {
                        user.picture_url = valueDict.valueForKey("url") as? String
                    }
                }
                
                UserService().UpdateUser(user, completion: { (isSuccess, object) -> Void in
                    if (isSuccess){
                        let dal = ProfilsDAL()
                        dal.update(user)
                    }
                })
            }
        })
    }
    
    public func unmergeProfilWithFacebook(user: Profil, completion: (isSuccess: Bool) -> Void){
        user.fb_id = ""
        user.fb_token = ""
        UserService().UpdateUser(user, completion: { (isSuccess, object) -> Void in
            if (isSuccess){
                let dal = ProfilsDAL()
                dal.update(user)
            }
            completion(isSuccess: isSuccess)
        })
        
    }
    
    public func showLoginPage(error: NSNotification){
        /* Display alert and redirect to login page */
        if let appDelegate = UIApplication.sharedApplication().delegate, let window = appDelegate.window {
            let alert = UIAlertController(title: "No Login title", message: "No Login message", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "", style: .Default, handler: { (alertAction) in
                //Go back to login page
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    let rootController:UIViewController = UIStoryboard(name: "Register", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginNavigationController")
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window!.makeKeyAndVisible()
                    appDelegate.window!.rootViewController = rootController
                    
                    //self.navigationController?.popToRootViewControllerAnimated(false)
                })
                
            }))
            dispatch_async(dispatch_get_main_queue(), {
                window!.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func updateStyle(profil: Profil){
        var styles = [String]()
        if profil.styles == nil {
            if let workStyle = profil.atWorkStyle {
                styles.append(workStyle)
                profil.atWorkStyle = nil
            }
            
            if let partyStyle = profil.onPartyStyle where !styles.contains(partyStyle) {
                styles.append(partyStyle)
                profil.onPartyStyle = nil
            }
            
            if let relaxStyle = profil.relaxStyle where !styles.contains(relaxStyle) {
                styles.append(relaxStyle)
                profil.relaxStyle = nil
            }
            
            profil.styles = styles.joinWithSeparator(",")
            //TODO Save new styles on back-end
            UserService().UpdateUser(profil, completion: { (isSuccess, object) -> Void in
                let profilDal = ProfilsDAL()
                profilDal.update(profil)
            })
        }
    }
}