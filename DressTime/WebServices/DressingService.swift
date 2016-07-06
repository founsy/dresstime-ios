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
import FBSDKCoreKit
import FBSDKLoginKit

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
    
    
    func UploadImage(clotheId: String, data: NSData,  completion: (isSuccess: Bool, object: JSON) -> Void){
        
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlDressing + "clothes/image/\(clotheId)"
            
            var request = NSMutableURLRequest(URL:  NSURL(string: path)!)
            request.HTTPMethod = "POST"
            
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
                request = NSMutableURLRequest(URL:  NSURL(string: path)!)
                request.HTTPMethod = "POST"
            } else {
                request.addValue("Bearer \(profil.access_token!)", forHTTPHeaderField: "Authorization")
            }
           
            
            Photo.upload(data, filename: "\(clotheId).jpg", request: request)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    print(totalBytesWritten)
                }
                .responseJSON { (response) in
                    print(response)
            }
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
            dict["clothe_image"] = ""
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


class Photo {
    class func upload(image: NSData, filename: String, request: NSMutableURLRequest) -> Request {
        let boundary = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        request.setValue("multipart/form-data;boundary="+boundary,
                         forHTTPHeaderField: "Content-Type")
        
        let parameters = NSMutableData()
        for s in ["\r\n--\(boundary)\r\n",
                  "Content-Disposition: form-data; name=\"clothe_image\";" +
                    " filename=\"\(filename)\"\r\n",
                  "Content-Type: image/png\r\n\r\n"] {
                    parameters.appendData(s.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        parameters.appendData(image)
        parameters.appendData("\r\n--\(boundary)--\r\n"
            .dataUsingEncoding(NSUTF8StringEncoding)!)
        return Alamofire.upload(request, data: parameters)
    }
}