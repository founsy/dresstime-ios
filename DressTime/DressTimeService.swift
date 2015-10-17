//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DressTimeService {
    let baseUrlOutfits = "http://api.drez.io/outfits/"
    let baseUrlDressing = "http://api.drez.io/dressing/"
    
    func GetOutfitsByStyle(style: String, weather: Weather, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsByStyle"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json[style])
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            var styles = [String]()
            styles.append(style)
            self.getOutfits(styles, weather:weather, completion: completion)
        }
    }
    
    func GetOutfitsToday(styles: [String], weather: Weather, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                var newJSON = [JSON]()
                for (_, subjson) in json {
                    if (subjson["style"].stringValue == styles[0] || subjson["style"].stringValue == styles[1]){
                        newJSON.append(subjson)
                    }
                }
                completion(isSuccess: true, object:JSON(newJSON))
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getOutfits(styles, weather: weather, completion: completion)
        }
    }
    
    func GetBrandOutfitsToday(completion: (isSuccess: Bool, object: JSON) -> Void){
        //if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsBrandToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
      /*  } else {
            self.getOutfitsToday(completion)
        } */
    }

    
    
    func SaveClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.saveClothe(clotheId, completion: completion)
        }
    }
    
    func GetDressing(completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getDressing(completion)
        }
    }
    
    func GetClothesIdDressing(completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getClothesIdDressing(completion)
        }
    }
    
    func GetClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getClothe(clotheId, completion: completion)
        }
    }
    
    func DeleteClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.deleteClothe(clotheId, completion: completion)
        }

    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    private func getOutfits(styles: [String], weather: Weather, completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            let dalClothe = ClothesDAL()
            let dressing = dalClothe.fetch()
            
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
            
            let weatherObject =  [
                "code" : weather.code!,
                "low" : weather.tempMin!,
                "high" : weather.tempMax!
            ]
            
            let parameters = [
                "sex" : profil.gender!,
                "styles" : styles,
                "dressing" : dressingSeriazible,
                "weather" : weatherObject
            ]
           
            
            let path = baseUrlOutfits

            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.POST, path, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
            //Cancel changes about ColorName
            dalClothe.managedObjectContext.reset()
            
            
        } else {
            completion(isSuccess: false, object: "")
        }
    }
    
    private func getOutfitsToday(styles: [String], weather: Weather, completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            let dalClothe = ClothesDAL()
            let dressing = dalClothe.fetch()
            
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
           
            
            let weatherObject =  [
                "code" : weather.code!,
                "low" : weather.tempMin!,
                "high" : weather.tempMax!
            ]
            
            let parameters = [
                "sex" : profil.gender!,
                "dressing" : dressingSeriazible,
                "weather" : weatherObject
            ]
            
           
            let path = baseUrlOutfits + "today"
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.POST, path, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                print(response.result.value)
                if response.result.isSuccess {
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
            //Cancel changes about ColorName
            dalClothe.managedObjectContext.reset()
            
        } else {
            completion(isSuccess: false, object: "")
        }
    }
    
    private func saveClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let clothe = ClothesDAL().fetch(clotheId) {
            if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
                var dressingSeriazible = [[String:AnyObject]]()
                
                let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
                let image:String = (dict["clothe_image"] as! NSData).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                dict["clothe_image"] = image
                let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
                dressingSeriazible.append(d)
                
                let parameters = [
                    "dressing" : dressingSeriazible
                ]
                
                let path = baseUrlDressing + "clothes/"
                let headers = ["Authorization": "Bearer \(profil.access_token!)"]
                Alamofire.request(.POST, path, parameters: parameters, encoding: .JSON, headers: headers).responseJSON { response in
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
        completion(isSuccess: false, object: "")
    }
    
    private func getDressing(completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let path = baseUrlDressing + "clothes/"
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.GET, path, encoding: .JSON, headers: headers).responseJSON { response in
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
    
    private func getClothesIdDressing(completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let path = baseUrlDressing + "clothesIds/"
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.GET, path, encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    print(response.result.value)
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                        /* //TODO - Convert msg to Array<String>
                        var idList = [String]()
                        if let array = msg["list"] as? NSArray {
                            for item in array{
                                if let obj = item as? NSDictionary {
                                    idList.append(obj["id"] as! String)
                                }
                            }
                        }*/
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        }
        completion(isSuccess: false, object: "")
    }
    
    private func getClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let path = baseUrlDressing + "clothes/" + clotheId
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.GET, path, encoding: .JSON, headers: headers).responseJSON { response in
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

    private func deleteClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let path = baseUrlDressing + "clothes/" + clotheId
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.DELETE, path, encoding: .JSON, headers: headers).responseJSON { response in
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