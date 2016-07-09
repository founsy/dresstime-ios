//
//  User.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON

public class User: NSObject {

    var email: String
    var username: String
    var displayName: String
    var password: String?
    
    var atWorkStyle: String?
    var onPartyStyle: String?
    var relaxStyle: String?
    
    var tempUnit: String = "C"
    var gender: String?
    var isVerified: Bool = false
    var picture: String?
    
    var fb_id: String?
    var fb_token: String?
    
    var access_token: String?
    var refresh_token: String?
    var expire_in: Int?
    
    var picture_data: NSData?
    
    public init(json: JSON) {
        var json = json
        access_token = json["access_token"].string
        refresh_token = json["refresh_token"].string
        expire_in = json["email"].int
        
        if let user = json["user"].dictionary {
            json = JSON(user)
        }
        email = json["email"].stringValue
        username = json["username"].stringValue
        displayName = json["displayName"].stringValue
        
        atWorkStyle = json["atWorkStyle"].stringValue
        onPartyStyle = json["onPartyStyle"].stringValue
        relaxStyle = json["relaxStyle"].stringValue
        
        tempUnit = json["tempUnit"].stringValue
        gender = json["gender"].stringValue
        isVerified = json["isVerified"].boolValue
        picture = json["picture"].string
        
        fb_id = json["fb_id"].string
        fb_token = json["fb_token"].string
      
    }
    
    public init(email: String, username: String?, displayName: String?){
        self.email = email
        self.username = username != nil ? username! : email
        self.displayName = displayName != nil ? displayName! : email
    }
    
    public init(profile: Profil){
        self.email = profile.email!
        self.username = profile.name != nil ? profile.name! : profile.email!
        self.displayName = profile.name != nil ? profile.name!: profile.email!
    }
}