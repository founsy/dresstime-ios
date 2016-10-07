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
    
    func UpdateUser(_ user: Profil, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        self.updateUser(user, completion: completion)
    }
    
    func CreateUser(_ user: Profil, password: String?, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        self.createUser(user, password: password, completion: completion)
    }
    
    func GetUser(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        self.getUser(completion)
    }


    fileprivate func createUser(_ user: Profil, password: String?, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let parameters : [String : Any]? = [
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
        
        Alamofire.request(URL(string: baseUrlRegistration)!, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON(completionHandler: { (response) in
            print(response.result.value)
            switch response.result {
            case .success(let json):
                let jsonDic = JSON(json)
                completion(true, jsonDic)
            case .failure(let error):
                print(error)
                if let data = response.data {
                    let json = JSON(data: data)
                    print("Failure Response: \(json)")
                    completion(false, json)
                    
                }
                completion(false, JSON(error))
            }
        })

    }
    
    
    fileprivate func updateUser(_ user: Profil, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
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
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    let jsonDic = JSON(json)
                    completion(true, jsonDic)
                case.failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
        completion(false, "")
    }
    
    fileprivate func getUser(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        var path = self.baseUrlUser
        var headers :[String : String]?
        if ((FBSDKAccessToken.current()) != nil){
            path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
        } else {
            if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
                 headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
        }
        Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                let jsonDic = JSON(json)
                completion(true, jsonDic)
            case.failure(let error):
                completion(false, JSON(error))
            }
        })
    }
    
}
