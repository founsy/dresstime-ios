//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import FBSDKCoreKit
import FBSDKLoginKit

class DressTimeService {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        static let baseURL = PListReader.getStringProperty("serverURLDebug")
    #else
        static let baseURL = PListReader.getStringProperty("serverURL")
    #endif
    
    
    let baseUrlOutfits = "\(baseURL)outfits/"
    let baseUrlBrand = "\(baseURL)brand/"
    
    func GetOutfitsToday(_ location: CLLocation, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("\(SharedData.sharedInstance.currentUserId!)-OutfitsToday"){
                var json = JSON(data: nsdata)
                var newJSON = [JSON]()
                let moment = WeatherWrapper().getNameByTime(json["weather"][0]["hour"].intValue).lowercased()
                
                for (_, subjson) in json["outfits"][moment] {
                    if (subjson["style"].stringValue == "fashion" || subjson["style"].stringValue == "casual"){
                        newJSON.append(subjson)
                    }
                }
                json["outfits"] = JSON(newJSON)
                completion(true, json)
            } else {
                completion(false, "")
            }
        } else {
            self.getOutfits(location, completion: completion)
        }
    }
    
    func GetOutfitsPutOn(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        self.getOutfitsPutOn(completion)
    }
    
    func GetBrandClothes(_ completion: @escaping (_ isSuccess: Bool, _ object:  [BrandClothe]?) -> Void){
        self.getBrandClothes(completion)
    }
    
    func SaveOutfit(_ outfit: Outfit, completion: @escaping (_ isSuccess: Bool) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                _ = JSON(data: nsdata)
                completion(true)
            } else {
                completion(false)
            }
        } else {
            self.saveOutfit(outfit, completion: completion)
        }
    }
    
    
    fileprivate func jsonToBrandClothe(_ json: JSON) -> [BrandClothe] {
        var brandClothes = [BrandClothe]()
        for i in 0...json.arrayValue.count-1{
            brandClothes.append(BrandClothe(json: json.arrayValue[i]))
        }
        return brandClothes
    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    fileprivate func getOutfits(_ location: CLLocation, completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let userId = SharedData.sharedInstance.currentUserId,
            let profil = dal.fetch(userId) {
           
            var path = baseUrlOutfits + "v2.2/?lat=\(location.coordinate.latitude)&long=\(location.coordinate.longitude)&timezone=\(NSTimeZone.system.secondsFromGMT())"
            
            var headers :[String : String]?
            
            let preferredLanguage:NSString = Locale.preferredLanguages[0] as NSString
            let lang = preferredLanguage.substring(to: 2)
            
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                headers = ["Accept-Language" : lang]
                path = path + "&access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                if let token = profil.access_token {
                    headers = ["Authorization": "Bearer \(token)", "Accept-Language" : lang]
                } else {
                    completion(false, "")
                }
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print("Success getOutfits")
                    completion(true, JSON(json))
                case .failure(let error):
                    if let error = error as NSError? {
                        if error.code == 401 {
                            NotificationCenter.default.post(name: Notifications.Error.NoAuthentication, object: nil)
                        } else {
                            print(error.localizedDescription)
                            completion(false, JSON(error.localizedDescription))
                        }
                    }
                }
            })
        } else {
            completion(false, "")
        }
    }
    
    
    fileprivate func getOutfitsPutOn(_ completion: @escaping (_ isSuccess: Bool, _ object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            var path = baseUrlOutfits + "outfitsPutOn";
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                if let token = profil.access_token {
                    headers = ["Authorization": "Bearer \(token)"]
                } else {
                    completion(false, "")
                }
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print("Success getOutfits")
                    completion(true, JSON(json))
                case .failure(let error):
                    if let error = error as NSError? {
                        print(error.localizedDescription)
                        completion(false, JSON(error.localizedDescription))
                    }
                }
            })

        } else {
        completion(false, "")
        }
    }


    fileprivate func getBrandClothes(_ completion: @escaping (_ isSuccess: Bool, _ object: [BrandClothe]?) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            var path = self.baseUrlBrand
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                if response.result.isSuccess {
                    let jsonDic = JSON(response.result.value!)
                    completion(true, self.jsonToBrandClothe(jsonDic))
                } else {
                    completion(false, nil)
                }
            })
        } else {
            completion(false, nil)
        }
    }
    
    fileprivate func saveOutfit(_ outfit: Outfit, completion: @escaping (_ isSuccess: Bool) -> Void){
        //Save outfit but remove images before
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlOutfits + "OOTD"
            var headers :[String : String]?
            if ((FBSDKAccessToken.current()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.current().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(URL(string: path)!, method: HTTPMethod.post, parameters: outfit.toDictionnary() as? [String : AnyObject], encoding: JSONEncoding.default, headers: headers).validate().responseJSON(completionHandler: { (response) in
                if response.result.isSuccess {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
}
