//
//  LoginService.swift
//  DressTime
//
//  Created by Fab on 07/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import Alamofire

class LoginService {
    
    let base_url = "\(DressTimeService.baseURL)oauth/"
    let base_url_auth = "\(DressTimeService.baseURL)auth/"
    let base_url_email = "\(DressTimeService.baseURL)email/"
    
    
    let isDebug = true
    static let clientId = "android"
    static let grantTypePassword = "password"
    static let grantTypeRefresh = "refresh_token"
    static let clientSecret = "SomeRandomCharsAndNumbers"
    
    
    func Login(login: String, password: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        self.login(login, password: password, completion: completion)
    }
    
    func Logout(access_token: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("logout"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.logout(access_token, completion: completion)
        }
    }
    
    func SendVerificationEmail(email: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(isSuccess: true, object: "")
        } else {
            self.sendVerificationEmail(email, completion: completion)
        }
    }
    
    func RefreshToken(refreshToken: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("refreshToken"){
                let str = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                print(str)
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.refreshToken(refreshToken, completion: completion)
        }
    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    //POST
    private func login(login: String, password: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        let parameters = [
            "grant_type" : LoginService.grantTypePassword,
            "client_id" : LoginService.clientId,
            "client_secret" : LoginService.clientSecret,
            "username" : login,
            "password" : password
        ]
        let path = base_url + "token"
        Alamofire.request(.POST, path, parameters: parameters, encoding: .JSON).responseJSON { response in
            var statusCode = 200
            if let httpError = response.result.error {
                statusCode = httpError.code
            } else { //no errors
                statusCode = (response.response?.statusCode)!
            }
            
            if statusCode == 200 {
                print(response.result.value)
                let jsonDic = JSON(response.result.value!)
                completion(isSuccess: true, object: jsonDic)
            } else {
                if let value = response.result.value {
                    let jsonDic = JSON(value)
                    completion(isSuccess: false, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }
    }
    
    //GET
    private func logout(accessToken: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            var path = base_url_auth + "logout"

            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(.GET, path, parameters: nil, encoding: .JSON, headers: headers).responseJSON { (response) -> Void in
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
    
    private func sendVerificationEmail(email: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        let path =  "\(base_url_email)send?email=\(email)"
        Alamofire.request(.GET, path, parameters: nil, encoding: .JSON).responseJSON { (response) -> Void in
            if response.result.isSuccess {
                print(response.result.value)
                let jsonDic = JSON(response.result.value!)
                completion(isSuccess: true, object: jsonDic)
            } else {
                completion(isSuccess: false, object: "")
            }
        }
    }
    
    private func refreshToken(refreshToken: String, completion:(isSuccess: Bool, object: JSON) -> Void) {
        let parameters = [
            "grant_type" : LoginService.grantTypeRefresh,
            "client_id" : LoginService.clientId,
            "client_secret" : LoginService.clientSecret,
            "refresh_token" : refreshToken
        ]
        let path = base_url + "token"
        Alamofire.request(.POST, path, parameters: parameters, encoding: .JSON).responseJSON { response in
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


public class Mock {
    static func isMockable() -> Bool{
       return (SharedData.sharedInstance.currentUserId?.lowercaseString == "alexandre" || SharedData.sharedInstance.currentUserId?.lowercaseString == "juliette")
    }
}