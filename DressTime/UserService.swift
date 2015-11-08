//
//  UserService.swift
//  DressTime
//
//  Created by Fab on 07/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import Alamofire

class UserService {
    let baseUrlUser = "http://api.drez.io/users/"
    
    func GetBrandOutfitsToday(user: Profil, completion: (isSuccess: Bool, object: JSON) -> Void){
        /*if (Mock.isMockable()){
        if let nsdata = ReadJsonFile().readFile("\(SharedData.sharedInstance.currentUserId!)-OutfitsBrandToday"){
            let json = JSON(data: nsdata)
            completion(isSuccess: true, object:json)
        } else {
            completion(isSuccess: false, object: "")
        }
          } else { */
        self.updateUser(user, completion: completion)
        /*} */
    }

    
    private func updateUser(user: Profil, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            
            let parameters = [
                "email" : user.email != nil ? user.email! : "",
                "displayName" : user.name != nil ? user.name! : "",
                "atWorkStyle" : user.atWorkStyle != nil ? user.atWorkStyle! : "",
                "onPartyStyle" : user.onPartyStyle != nil ? user.onPartyStyle! : "",
                "relaxStyle" : user.relaxStyle != nil ? user.relaxStyle! : "",
                "tempUnit" : user.temp_unit!,
                "gender" : user.gender!
            ]
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.PUT, baseUrlUser, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
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
    
}