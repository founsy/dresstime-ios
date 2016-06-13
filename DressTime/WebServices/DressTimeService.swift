//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//
import UIKit
import Alamofire
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
    
    func GetOutfitsToday(location: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("\(SharedData.sharedInstance.currentUserId!)-OutfitsToday"){
                var json = JSON(data: nsdata)
                var newJSON = [JSON]()
                let moment = WeatherWrapper().getNameByTime(json["weather"][0]["hour"].intValue).lowercaseString
                
                for (_, subjson) in json["outfits"][moment] {
                    if (subjson["style"].stringValue == "fashion" || subjson["style"].stringValue == "casual"){
                        newJSON.append(subjson)
                    }
                }
                json["outfits"] = JSON(newJSON)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getOutfits(location, completion: completion)
        }
    }
    
    func GetOutfitsPutOn(completion: (isSuccess: Bool, object: JSON) -> Void){
        self.getOutfitsPutOn(completion)
    }
    
    func GetBrandClothes(completion: (isSuccess: Bool, object:  [BrandClothe]?) -> Void){
        self.getBrandClothes(completion)
    }
    
    func SaveOutfit(outfit: Outfit, completion: (isSuccess: Bool) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("outfitsToday"){
                _ = JSON(data: nsdata)
                completion(isSuccess: true)
            } else {
                completion(isSuccess: false)
            }
        } else {
            self.saveOutfit(outfit, completion: completion)
        }
    }
    
    
    private func jsonToBrandClothe(json: JSON) -> [BrandClothe] {
        var brandClothes = [BrandClothe]()
        for i in 0...json.arrayValue.count-1{
            brandClothes.append(BrandClothe(json: json.arrayValue[i]))
        }
        return brandClothes
    }
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    private func getOutfits(location: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let userId = SharedData.sharedInstance.currentUserId,
            let profil = dal.fetch(userId) {
           
            var path = baseUrlOutfits + "v2.1/?lat=\(location.coordinate.latitude)&long=\(location.coordinate.longitude)&timezone=\(NSTimeZone.systemTimeZone().secondsFromGMT)"
            
            var headers :[String : String]?
            
            let preferredLanguage:NSString = NSLocale.preferredLanguages()[0]
            let lang = preferredLanguage.substringToIndex(2)
            
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                headers = ["Accept-Language" : lang]
                path = path + "&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                if let token = profil.access_token {
                    headers = ["Authorization": "Bearer \(token)", "Accept-Language" : lang]
                } else {
                    completion(isSuccess: false, object: "")
                }
               
            }
            
            
            Alamofire.request(.GET, path, parameters: nil, encoding: .JSON, headers: headers).validate().responseJSON { response in
                    switch response.result {
                    case .Success(let json):
                        print("Success getOutfits")
                        completion(isSuccess: true, object: JSON(json))
                    case .Failure(let error):
                        if let error = error as NSError? {
                            print(error.localizedDescription)
                            completion(isSuccess: false, object: JSON(error.localizedDescription))
                        }
                }
            }
        } else {
            completion(isSuccess: false, object: "")
        }
    }
    
    
    private func getOutfitsPutOn(completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            
            var path = baseUrlOutfits + "outfitsPutOn";
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "&access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                if let token = profil.access_token {
                    headers = ["Authorization": "Bearer \(token)"]
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
            
            Alamofire.request(.GET, path, parameters: nil, encoding: .JSON, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .Success(let json):
                    print("Success getOutfits")
                    completion(isSuccess: true, object: JSON(json))
                case .Failure(let error):
                    if let error = error as NSError? {
                        print(error.localizedDescription)
                        completion(isSuccess: false, object: JSON(error.localizedDescription))
                    }
                }
            }

        } else {
        completion(isSuccess: false, object: "")
        }
    }


    private func getBrandClothes(completion: (isSuccess: Bool, object: [BrandClothe]?) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            var path = self.baseUrlBrand
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
            
            Alamofire.request(.GET, path, parameters: nil, encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: self.jsonToBrandClothe(jsonDic))
                } else {
                    completion(isSuccess: false, object: nil)
                }
            }
        } else {
            completion(isSuccess: false, object: nil)
        }
    }
    
    private func saveOutfit(outfit: Outfit, completion: (isSuccess: Bool) -> Void){
        //Save outfit but remove images before
        if let profil = ProfilsDAL().fetch(SharedData.sharedInstance.currentUserId!) {
            var path = baseUrlOutfits + "OOTD"
            var headers :[String : String]?
            if ((FBSDKAccessToken.currentAccessToken()) != nil && profil.fb_id != nil){
                path = path + "?access_token=\(FBSDKAccessToken.currentAccessToken().tokenString)"
            } else {
                headers = ["Authorization": "Bearer \(profil.access_token!)"]
            }
  
            Alamofire.request(.POST, path, parameters: outfit.toDictionnary() as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    completion(isSuccess: true)
                } else {
                    completion(isSuccess: false)
                }
            }
        }
    }
    
}