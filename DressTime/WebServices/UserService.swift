//
//  UserService.swift
//  DressTime
//
//  Created by Fab on 07/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit

class UserService {
    let baseUrlUser = "\(DressTimeService.baseURL)users/"
    let baseUrlRegistration = "\(DressTimeService.baseURL)auth/registration"
    
    func UpdateUser(user: Profil, completion: (isSuccess: Bool, object: JSON) -> Void){
        self.updateUser(user, completion: completion)
    }
    
    func CreateUser(user: Profil, password: String?, completion: (isSuccess: Bool, object: JSON) -> Void){
        self.createUser(user, password: password, completion: completion)
    }
    
    func GetUser(completion: (isSuccess: Bool, object: JSON) -> Void){
        self.getUser(completion)
    }


    private func createUser(user: Profil, password: String?, completion: (isSuccess: Bool, object: JSON) -> Void){
        let parameters : [String : AnyObject]? = [
            "email" : user.email != nil ? user.email! : "",
            "password" : password != nil ? password! : "",
            "username" : user.email != nil ? user.email! : "",
            "displayName" : user.name != nil ? user.name! : "",
            "notification" : user.notification != nil ? user.notification! : "",
            "styles" : user.styles != nil ? user.styles! : "",
            "tempUnit" : user.temp_unit!,
            "gender" : user.gender!,
            "fb_id" : user.fb_id != nil ? user.fb_id! : "",
            "fb_token" : user.fb_token != nil ? user.fb_token! : "",
            "picture" : user.picture_url != nil ? user.picture_url! : "",
            "firstName" : user.firstName != nil ? user.firstName! : "",
            "lastName" : user.lastName != nil ? user.lastName! : ""
        ]
        
        Alamofire.request(.POST, baseUrlRegistration, parameters: parameters, encoding: .JSON).validate().responseJSON { response in
            print(response.result.value)
            switch response.result {
            case .Success:
                let jsonDic = JSON(response.result.value!)
                completion(isSuccess: true, object: jsonDic)
            case .Failure(let error):
                print(error)
                if let data = response.data {
                    let json = JSON(data: data)
                    print("Failure Response: \(json)")
                    completion(isSuccess: false, object: json)
                    
                }
                completion(isSuccess: false, object: JSON(error))
            }
        }

    }
    
    
    private func updateUser(user: Profil, completion: (isSuccess: Bool, object: JSON) -> Void){
        //TODO - Check if currentUserId available
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            
            let parameters = [
                "email" : user.email != nil ? user.email! : "",
                "displayName" : user.name != nil ? user.name! : "",
                "styles" : user.styles != nil ? user.styles! : "",
                "notification" : user.notification != nil ? user.notification! : "",
                "tempUnit" : user.temp_unit!,
                "gender" : user.gender!,
                "fb_id" : user.fb_id != nil ? user.fb_id! : "",
                "fb_token" : user.fb_token != nil ? user.fb_token! : "",
                "picture" : user.picture_url != nil ? user.picture_url! : "",
                "firstName" : user.firstName != nil ? user.firstName! : " ",
                "lastName" : user.lastName != nil ? user.lastName! : " "
            ]
            
            var path = self.baseUrlUser
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(.PUT, path, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }
        completion(isSuccess: false, object: "")
    }
    
    private func getUser(completion: (isSuccess: Bool, object: JSON) -> Void){
        var path = self.baseUrlUser
        var headers :[String : String]?
        if ((FBSDKAccessToken.currentAccessToken()) != nil){
            path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
        } else {
            if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
                 headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
        }
        
        Alamofire.request(.GET, path, parameters: nil, encoding: .JSON, headers: headers).responseJSON { response in
            print(response.result.value)
            if response.result.isSuccess {
                print(response.result.value)
                let jsonDic = JSON(response.result.value!)
                completion(isSuccess: true, object: jsonDic)
            } else {
                completion(isSuccess: false, object: "")
            }
        }
    }
    
}