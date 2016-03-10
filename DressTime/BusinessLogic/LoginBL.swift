//
//  LoginBL.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

public class LoginBL {
    
    //Update
    public func loginWithSuccess(object: JSON){
        let dal = ProfilsDAL()
        let user = User(json: object)
        
        //If profil already exist update
        if let profil = dal.fetch(user.email.lowercaseString) {
            profil.access_token = user.access_token
            profil.refresh_token = user.refresh_token
            profil.expire_in = user.expire_in
            if let id = profil.fb_id {
                profil.picture = NSData(contentsOfURL: NSURL(string: "https://graph.facebook.com/\(id)/picture?width=100&height=100")!)
            }
            dal.update(profil)
        } else {
            dal.save(user)
        }
        
        SharedData.sharedInstance.currentUserId = user.email
        SharedData.sharedInstance.sexe = user.gender
        
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
    
    public func logoutWithSuccess(user: Profil){
        let dal = ProfilsDAL()
        let profilOld = dal.fetch(user.userid!)
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
}