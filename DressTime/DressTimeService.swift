//
//  DressTimeService.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//
import UIKit
import Alamofire

class DressTimeService {
    let baseUrlOutfits = "http://api.drez.io/outfits/"
    let baseUrlBrand = "http://api.drez.io/brand/"
    
    func GetOutfitsToday(styles: [String], weather: Weather, completion: (isSuccess: Bool, object: JSON) -> Void){
        if (Mock.isMockable()){
            if let nsdata = ReadJsonFile().readFile("\(SharedData.sharedInstance.currentUserId!)-OutfitsToday"){
                print(weather)
                let json = JSON(data: nsdata)
                var newJSON = [JSON]()
                var moment = weather.time!.lowercaseString
                if (moment == "now"){
                      moment = WeatherWrapper().getNameByTime(weather.hour!).lowercaseString
                }
                for (_, subjson) in json[moment] {
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
            
            
            let path = baseUrlOutfits + "/v2"
            
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            
            Alamofire.request(.POST, path, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).validate().responseJSON { response in
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
    private func getBrandClothes(completion: (isSuccess: Bool, object: JSON) -> Void){
        let dal = ProfilsDAL()
        if let profil = dal.fetch(SharedData.sharedInstance.currentUserId!) {
            let headers = ["Authorization": "Bearer \(profil.access_token!)"]
            Alamofire.request(.GET, "http://api.drez.io/brand/", parameters: nil, encoding: .JSON, headers: headers).responseJSON { response in
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