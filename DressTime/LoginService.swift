//
//  LoginService.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

class LoginService {


    class func loginMethod(params : [String: AnyObject], postCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()){
        JSONService.post(params, url: "http://api.drez.io/oauth/token", postCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
             if (succeeded){
                var error : NSError?
                
                if (result["error"] != nil){
                    postCompleted(succeeded: false, msg: result)
                } else {
                    postCompleted(succeeded: true, msg: result)
                }

             } else {
                postCompleted(succeeded: false, msg: ["error" : "Login failed."])
            }
            
        })
    
    }
    
    class func logoutMethod(params : [String: AnyObject], getCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()){
        JSONService.get("http://api.drez.io/auth/logout", params: params, getCompleted: { (succeeded: Bool, result: [String: AnyObject]) -> () in
            if (succeeded){
                var error : NSError?
                
                if (result["error"] != nil){
                    getCompleted(succeeded: false, msg: result)
                } else {
                    getCompleted(succeeded: true, msg: result)
                }
                
            } else {
                getCompleted(succeeded: false, msg: ["error" : "Login failed."])
            }
            
        })
        
    }
    
}