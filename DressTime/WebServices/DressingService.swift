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
import SwiftyJSON
import FBSDKCoreKit
import FBSDKLoginKit



class DressingService {
    let baseUrlDressing = "\(DressTimeService.baseURL)dressing/"
    
    func UpdateClothe(_ clothe: Clothe, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(true, nil)
        } else {
            self.updateClothe(clothe, completion: completion)
        }
    }
    
    func GetImageClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            completion(true, nil)
        } else {
            self.getImageClothe(clotheId, completion: completion)
        }
    }
    
    
    func UploadImage(_ clotheId: String, data: Data,  completion: (_ isSuccess: Bool, _ object: JSON) -> Void){
        
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/image/\(clotheId)"
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            let URL = try! URLRequest(url: path, method: .post, headers: headers)
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: "clothe_image", fileName: "\(clotheId).jpg", mimeType: "image/jpeg")
                }, with: URL, encodingCompletion: { (result) in
                    print(result)
            })
        }
    }
    
    
    func SaveClothe(_ clothe: Clothe, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.saveClothe(clothe, completion: completion)
        }
    }
    
    func GetDressing(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.getDressing(completion)
        }
    }
    
    func GetClothesIdDressing(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.getClothesIdDressing(completion)
        }
    }
    
    func GetClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.getClothe(clotheId, completion: completion)
        }
    }
    
    func DeleteClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                let json = JSON(data: nsdata)
                completion(true, json)
            } else {
                completion( false, "")
            }
        } else {
            self.deleteClothe(clotheId, completion: completion)
        }
        
    }

   
    /*************************************/
     /*           PRIVATE FUNCTION        */
     /*************************************/
    
    fileprivate func saveClothe(_ clothe: Clothe, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var dressingSeriazible = [[String:AnyObject]]()
            
            let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
            dict["clothe_image"] = ""
            let d:[String:AnyObject] = dict as NSDictionary as! [String : AnyObject]
            dressingSeriazible.append(d)
            
            let parameters = [
                "dressing" : dressingSeriazible
            ]
            
            var path = baseUrlDressing + "clothes/"
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
    }
    
    fileprivate func updateClothe(_ clothe: Clothe, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            let dict = NSMutableDictionary(dictionary: clothe.toDictionnary())
            dict.removeObject(forKey: "clothe_image")
            
            var path = baseUrlDressing + "clothes/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.put, parameters: dict as? [String : AnyObject], encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
    }
    
    fileprivate func getDressing(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
        completion(false, "")
    }
    
    fileprivate func getClothesIdDressing(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothesIds/"
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
            
        }
        completion(false, "")
    }
    
    fileprivate func getClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
        completion(false, "")
    }
    
    fileprivate func getImageClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/image/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
        completion(false, "")
    }
    
    fileprivate func deleteClothe(_ clotheId: String, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/" + clotheId
            
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    completion(true, JSON(json))
                case .failure(let error):
                    completion(false, JSON(error))
                }
            })
        }
        completion(false, "")
    }
}
