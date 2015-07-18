//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation


class DressTimeService {
    
    class func getTodayOutfits(userid: String, style: String, dressing: [Clothe], todayCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()){
        var q = "http://api.drez.io/zara/myoutfits"
        
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userid) {
        
            let jsonObject: [String: AnyObject] = [
                "sex": profil.gender,
                "style": style,
                "dressing": dressing,
                "token": profil.access_token
            ];
            
            JSONService.post(jsonObject, url: q, postCompleted:  { (succeeded: Bool, result: [String: AnyObject]) -> () in
                    todayCompleted(succeeded: true, msg: result)
            })
        }
        
        

    }

}