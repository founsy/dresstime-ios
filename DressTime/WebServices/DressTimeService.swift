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

class DressTimeService {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        static let baseURL = PListReader.getStringProperty("serverURLDebug")
    #else
        static let baseURL = PListReader.getStringProperty("serverURL")
    #endif
    
    
    let baseUrlOutfits = "\(baseURL)outfits/" //"http://api.drez.io/outfits/"
    let baseUrlBrand = "\(baseURL)brand/"//"http://api.drez.io/brand/"
    
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
    
    func GetBrandClothes(completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            var nameFile = ""
            if (SharedData.sharedInstance.sexe == "M") {
                nameFile = "alexandre-Shopping"
            } else {
                nameFile = "juliette-Shopping"
            }
            if let nsdata = ReadJsonFile().readFile(nameFile){
                let json = JSON(data: nsdata)
                completion(isSuccess: true, object:json)
            } else {
                completion(isSuccess: false, object: "")
            }
        } else {
            self.getBrandClothes(completion)
        }
    }

    func GetBrandOutfitsToday(completion: (isSuccess: Bool, object: JSON) -> Void){
        //if (Mock.isMockable()){
        var nameFile = ""
        if (SharedData.sharedInstance.sexe == "M") {
            nameFile = "alexandre-OutfitsBrandToday"
        } else {
            nameFile = "juliette-OutfitsBrandToday"
        }
        if let nsdata = ReadJsonFile().readFile(nameFile){
            let json = JSON(data: nsdata)
            completion(isSuccess: true, object:json)
        } else {
            completion(isSuccess: false, object: "")
        }

        /*  } else {
        self.getOutfitsToday(completion)
        } */
    }
    
    
    /*************************************/
    /*           PRIVATE FUNCTION        */
    /*************************************/
    
    private func getOutfits(location: CLLocation, completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
           

            let path = baseUrlOutfits + "v2.1/?lat=\(location.coordinate.latitude)&long=\(location.coordinate.longitude)&timezone=\(NSTimeZone.systemTimeZone().secondsFromGMT)"
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            
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
    private func getBrandClothes(completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.GET, self.baseUrlBrand, parameters: nil, encoding: .JSON, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let jsonDic = JSON(response.result.value!)
                    completion(isSuccess: true, object: jsonDic)
                } else {
                    completion(isSuccess: false, object: "")
                }
            }
        } else {
            completion(isSuccess: false, object: "")
        }
    }
}