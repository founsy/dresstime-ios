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
    let base_url = "http://api.drez.io/oauth/"
    let isDebug = true
    let clientId = "android"
    let grantTypePassword = "password"
    let grantTypeRefresh = "refresh_token"
    let clientSecret = "SomeRandomCharsAndNumbers"
    
    
    func Login(login: String, password: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (login.lowercaseString == "alexandre" || login.lowercaseString == "juliette"){
            if let nsdata = ReadJsonFile().readFile("login"){
                _ = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.login(login, password: password, completion: completion)
        }
    }
    
    func Logout(access_token: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("logout"){
                let str = NSString(data: nsdata, encoding:NSUTF8StringEncoding)
                print(str)
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.logout(access_token, completion: completion)
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
            "grant_type" : self.grantTypePassword,
            "client_id" : self.clientId,
            "client_secret" : self.clientSecret,
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
                completion(isSuccess: false, object: JSON("Error \(statusCode)"))
            }
        }
    }
    
    //GET
    private func logout(accessToken: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        let parameters = [
            "access_token" : accessToken
        ];
        let path = base_url + "logout"
        Alamofire.request(.GET, path, parameters: parameters, encoding: .JSON).responseJSON { (response) -> Void in
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
            "grant_type" : self.grantTypeRefresh,
            "client_id" : self.clientId,
            "client_secret" : self.clientSecret,
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