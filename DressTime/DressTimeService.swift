//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class DressTimeService {
    
    class func getOutfitsByStyle(userid: String, style: String, todayCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()){
        let q = "http://api.drez.io/outfits/byStyle"
        
        let dal = ProfilsDAL()
        let dalClothe = ClothesDAL()
        let dressing = dalClothe.fetch()
        
        if let profil = dal.fetch(userid) {
            var dressingSeriazible = [[String:AnyObject]]()
            let hexTranslator = HexColorToName()

            for clothe in dressing {
                let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
                let colorName = UIColor.colorWithHexString(dict["clothe_colors"] as! String)
                dict["clothe_colors"] = hexTranslator.name(colorName)[1] as! String
                dict.removeObjectForKey("clothe_image")
                let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
                dressingSeriazible.append(d)
            }
            
            let weatherObject: [String: String] =  [
                "code" : SharedData.sharedInstance.weatherCode!,
                "low" : SharedData.sharedInstance.lowTemp!,
                "high" : SharedData.sharedInstance.highTemp!
            ]
            
            let jsonObject: [String: AnyObject] = [
                "sex": profil.gender,
                "style": style,
                "dressing": dressingSeriazible,
                "weather": weatherObject,
                "access_token": profil.access_token
            ];
            print(jsonObject)
            //Cancel changes about ColorName
            dalClothe.managedObjectContext.reset()
            
            JSONService.post(jsonObject, url: q, postCompleted:  { (succeeded: Bool, result: [[String: AnyObject]]) -> () in
                    todayCompleted(succeeded: true, msg: result)
            })
        }
    }
    
    class func getOutfitsToday(userid: String, todayCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()){
        let q = "http://api.drez.io/outfits/today"
        
        let dal = ProfilsDAL()
        let dalClothe = ClothesDAL()
        let dressing = dalClothe.fetch()
        
        if let profil = dal.fetch(userid) {
            var dressingSeriazible = [[String:AnyObject]]()
            let hexTranslator = HexColorToName()
            
            for clothe in dressing {
                let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
                let colorName = UIColor.colorWithHexString(dict["clothe_colors"] as! String)
                dict["clothe_colors"] = hexTranslator.name(colorName)[1] as! String
                dict.removeObjectForKey("clothe_image")
                let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
                dressingSeriazible.append(d)
            }
            
            let weatherObject: [String: String] =  [
                "code" : SharedData.sharedInstance.weatherCode!,
                "low" : SharedData.sharedInstance.lowTemp!,
                "high" : SharedData.sharedInstance.highTemp!
            ]
            
            let jsonObject: [String: AnyObject] = [
                "sex": profil.gender,
                "dressing": dressingSeriazible,
                "weather": weatherObject,
                "access_token": profil.access_token
            ];
            print(jsonObject)
            //Cancel changes about ColorName
            dalClothe.managedObjectContext.reset()
            
            JSONService.post(jsonObject, url: q, postCompleted:  { (succeeded: Bool, result: [[String: AnyObject]]) -> () in
                todayCompleted(succeeded: true, msg: result)
            })
        }
    }
    
    class func saveClothe(userid: String,clotheId: String, dressingCompleted : (succeeded: Bool, msg: [[String: AnyObject]]) -> ()) {
        let q = "http://api.drez.io/dressing/clothes/"
        
        let dal = ProfilsDAL()
        let dalClothe = ClothesDAL()
        
        var dressingSeriazible = [[String:AnyObject]]()
        if let clothe = dalClothe.fetch(clotheId) {
            if let profil = dal.fetch(userid) {
                let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
                let image:String = (dict["clothe_image"] as! NSData).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                dict["clothe_image"] = image
                let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
                dressingSeriazible.append(d)
                
                let jsonObject: [String: AnyObject] = [
                    "dressing": dressingSeriazible,
                    "access_token": profil.access_token
                ]
                
                JSONService.post(jsonObject, url: q,  postCompleted : { (succeeded: Bool, msg: [[String: AnyObject]]) -> () in
                    dressingCompleted(succeeded: true, msg: msg)
                })
            }
        }
    }
    
    class func getDressing(userid: String, clotheCompleted : (succeeded: Bool, msg: [String: AnyObject]) -> ()) {
        let q = "http://api.drez.io/dressing/clothes/"
        
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userid) {
            let jsonObject: [String: AnyObject] = [
                "access_token": profil.access_token
            ]
            
            JSONService.get(q, params: jsonObject, getCompleted: { (succeeded, msg) -> () in
                print("Receive Dressing")
                clotheCompleted(succeeded: succeeded, msg: msg)
            })
        
        }
    }
    
    class func getClothesIdDressing(userid: String, clotheCompleted : (succeeded: Bool, idList: [String]) -> ()) {
        let q = "http://api.drez.io/dressing/clothesIds/"
        
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userid) {
            let jsonObject: [String: AnyObject] = [
                "access_token": profil.access_token
            ]
            
            JSONService.get(q, params: jsonObject, getCompleted: { (succeeded, msg) -> () in
                print("Receive Dressing")
                //TODO - Convert msg to Array<String>
                var idList = [String]()
                if let array = msg["list"] as? NSArray {
                    for item in array{
                        if let obj = item as? NSDictionary {
                            idList.append(obj["id"] as! String)
                        }
                    }
                }
                
                clotheCompleted(succeeded: succeeded, idList: idList )
            })
            
        }
        
    }
    
    class func getClothe(userid: String, clotheId: String, clotheCompleted : (succeeded: Bool, clothe: AnyObject) -> ()) {
        let q = "http://api.drez.io/dressing/clothes/" + clotheId
        
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userid) {
            let jsonObject: [String: AnyObject] = [
                "access_token": profil.access_token
            ]
            
            JSONService.get(q, params: jsonObject, getCompleted: { (succeeded, msg) -> () in
                print("Receive Clothe")
                //TODO - Convert msg to Array<String>
                
                clotheCompleted(succeeded: succeeded, clothe: msg)
            })
            
        }
    }
    
    class func deleteClothe(userid: String, clotheId: String, clotheDelCompleted : (succeeded: Bool, clothe: AnyObject) -> ()) {
        var q = "http://api.drez.io/dressing/clothes/" + clotheId
        
        let dal = ProfilsDAL()
        if let profil = dal.fetch(userid) {
            let jsonObject: [String: AnyObject] = [
                "access_token": profil.access_token
            ]
            
            JSONService.delete(q, params: jsonObject, deleteCompleted: { (succeeded, msg) -> () in
                print("Receive Clothe")
                //TODO - Convert msg to Array<String>
                
                clotheDelCompleted(succeeded: succeeded, clothe: msg)
            })
            
        }
    }

}