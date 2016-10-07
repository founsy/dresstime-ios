//
//  LoginService.swift
//  DressTime
//
//  Created by Fab on 07/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit

class LoginService {
    
    let base_url = "\(DressTimeService.baseURL)oauth/"
    let base_url_auth = "\(DressTimeService.baseURL)auth/"
    let base_url_email = "\(DressTimeService.baseURL)email/"
    
    
    let isDebug = true
    static let clientId = "android"
    static let grantTypePassword = "password"
    static let grantTypeRefresh = "refresh_token"
    static let clientSecret = "SomeRandomCharsAndNumbers"
    
    
    func Login(_ login: String, password: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        self.login(login, password: password, completion: completion)
    }
    
    func Logout(_ access_token: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("logout"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.logout(access_token, completion: completion)
        }
    }
    
    func SendVerificationEmail(_ email: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(true, "")
        } else {
            self.sendVerificationEmail(email, completion: completion)
        }
    }
    
    func RefreshToken(_ refreshToken: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("refreshToken"){
                let str = NSString(data: nsdata, encoding:String.Encoding.utf8.rawValue)
                print(str)
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.refreshToken(refreshToken, completion: completion)
        }
    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    //POST
    fileprivate func login(_ login: String, password: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let parameters = [
            "grant_type" : LoginService.grantTypePassword,
            "client_id" : LoginService.clientId,
            "client_secret" : LoginService.clientSecret,
            "username" : login,
            "password" : password
        ]
        let path = base_url + "token"
        Alamofire.request(URL(string: path)!, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                completion(true, JSON(json))
            case .failure(let error):
                completion(false, JSON(error))
            }
        })
    }
    
    //GET
    fileprivate func logout(_ accessToken: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            var path = base_url_auth + "logout"

            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
    }
    
    fileprivate func sendVerificationEmail(_ email: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let path =  "\(base_url_email)send?email=\(email)"
        
        Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                completion(true, JSON(json))
            case .failure(let error):
                completion(false, JSON(error))
            }
        })
    }
    
    fileprivate func refreshToken(_ refreshToken: String, completion:@escaping (_ isSuccess: Bool, _ object: JSON) -> Void) {
        let parameters = [
            "grant_type" : LoginService.grantTypeRefresh,
            "client_id" : LoginService.clientId,
            "client_secret" : LoginService.clientSecret,
            "refresh_token" : refreshToken
        ]
        let path = base_url + "token"
        
        Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                completion(true, JSON(json))
            case .failure(let error):
                completion(false, JSON(error))
            }
        })
    }
}


open class Mock {
    static func isMockable() -> Bool{
       return (SharedData.sharedInstance.currentUserId?.lowercased() == "alexandre" || SharedData.sharedInstance.currentUserId?.lowercased() == "juliette")
    }
}
