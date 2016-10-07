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
    let baseUrlDressing = "\(DressTimeService.baseURL)dressing/"//"http://api.drez.io/dressing/"
    
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
            
            var request = NSMutableURLRequest(url:  URL(string: path)!)
            request.httpMethod = "POST"
            
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
                request = NSMutableURLRequest(url:  URL(string: path)!)
                request.httpMethod = "POST"
            } else {
                request.addValue("Bearer \(profil.access_token!)", forHTTPHeaderField: "Authorization")
            }
        
          /*  Photo.upload(data as NSData, filename: "\(clotheId).jpg", request: request)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    print(totalBytesWritten)
                }
                .responseJSON { (response) in
                    print(response)
            } */
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

/*
class Photo {
    class func upload(_ image: NSData, filename: String, request: NSMutableURLRequest) -> Request {
        let boundary = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        request.setValue("multipart/form-data;boundary="+boundary,
                         forHTTPHeaderField: "Content-Type")
        
        let parameters = NSMutableData()
        for s in ["\r\n--\(boundary)\r\n",
                  "Content-Disposition: form-data; name=\"clothe_image\";" +
                    " filename=\"\(filename)\"\r\n",
                  "Content-Type: image/png\r\n\r\n"] {
                    parameters.append(s.data(using: String.Encoding.utf8)!)
        }
        parameters.append(image as Data)
        parameters.append("\r\n--\(boundary)--\r\n"
            .data(using: String.Encoding.utf8)!)
        
        return Alamofire.upload(parameters, to: request) //Alamofire.upload(request, data: parameters)
    }
} */
