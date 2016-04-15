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
    
    func UpdateClothe(clothe: Clothe, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(isSuccess: true, object:nil)
        } else {
            self.updateClothe(clothe, completion: completion)
        }
    }
    
    func GetImageClothe(clotheId: String, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(isSuccess: true, object:nil)
        } else {
            self.getImageClothe(clotheId, completion: completion)
        }
    }
    
    func SaveClothe(clothe: Clothe, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.saveClothe(clothe, completion: completion)
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
    
    private func saveClothe(clothe: Clothe, completion: (isSuccess: Bool, object: JSON) -> Void){
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
            
            var path = baseUrlDressing + "clothes/"
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
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
    
    private func updateClothe(clothe: Clothe, completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
            dict.removeObjectForKey("clothe_image")
            
            var path = baseUrlDressing + "clothes/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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
    
    private func getDressing(completion: (isSuccess: Bool, object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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
            var path = baseUrlDressing + "clothesIds/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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
            var path = baseUrlDressing + "clothes/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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
            var path = baseUrlDressing + "clothes/image/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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
            var path = baseUrlDressing + "clothes/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
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