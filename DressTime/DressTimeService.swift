//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation


class DressTimeService {
    
    class func getTodayOutfits(userid: String, style: String, todayCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()){
        var q = "http://api.drez.io/zara/myoutfits"
        
        let dal = ProfilsDAL()
        let dalClothe = ClothesDAL()
        let dressing = dalClothe.fetch()
        var dressingSeriazable = [[String:AnyObject]]()
        
        if let profil = dal.fetch(userid) {
            let hexTranslator = HexColorToName()
            for clothe in dressing {
                let colorName = hexTranslator.colorWithHexString(clothe.clothe_colors)
                clothe.clothe_colors = hexTranslator.name(colorName)[1] as! String
                dressingSeriazable.append(clothe.toDictionnary())
            }
            
            let jsonObject: [String: AnyObject] = [
                "sex": profil.gender,
                "style": style,
                "dressing": dressingSeriazable,
                "token": profil.access_token
            ];
            
            JSONService.post(jsonObject, url: q, postCompleted:  { (succeeded: Bool, result: [[String: AnyObject]]) -> () in
                    todayCompleted(succeeded: true, msg: result)
            })
        }
        
        

    }

}