//
//  ClotheService.swift
//  DressTime
//
//  Created by Fab on 11/11/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DressingService {
    let baseUrlDressing = "\(DressTimeService.baseURL)dressing/"//"http://api.drez.io/dressing/"
    
    func UpdateClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(isSuccess: true, object:nil)
        } else {
            self.updateClothe(clotheId, completion: completion)
        }
    }
    
    func GetImageClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(isSuccess: true, object:nil)
        } else {
            self.getImageClothe(clotheId, completion: completion)
        }
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

    func SaveOutfit(outfit: [String], style: String, completion: (isSuccess: Bool) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true)
            } else {
                completion(isSuccess: false)
            }
        } else {
            self.saveOutfit(outfit, style: style, completion: completion)
        }
    }
    /*************************************/
     /*           PRIVATE FUNCTION        */
     /*************************************/
    
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
    
    private func updateClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let clothe = ClothesDAL().fetch(clotheId) {
            if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
                let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
                dict.removeObjectForKey("clothe_image")

                let path = baseUrlDressing + "clothes/"
                let headers = ["Authorization": "Bearer \(profil.access_token!)"]
                Alamofire.request(.PUT, path, parameters: dict as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
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
    }
    
    private func saveOutfit(outfit: [String], style: String, completion: (isSuccess: Bool) -> Void){
        //Save outfit but remove images before
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let parameters = [
                "style" : style,
                "clothes" : outfit
            ];
            let path = baseUrlDressing + "clothes/OOTD"
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.POST, path, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    completion(isSuccess: true)
                } else {
                    completion(isSuccess: false)
                }
            }
        }
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
    
    private func getImageClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let path = baseUrlDressing + "clothes/image/" + clotheId
            
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