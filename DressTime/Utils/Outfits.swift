//
//  Outfits.swift
//  DressTime
//
//  Created by Fab on 22/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

public class ClotheModel: NSObject {
    var clothe_colors: String
    var clothe_litteralColor: String
    var clothe_cut: String
    var clothe_id: String
    var clothe_image: String
    var clothe_isUnis: Bool
    var clothe_name: String
    var clothe_partnerid: NSNumber
    var clothe_partnerName: String
    var clothe_pattern: String
    var clothe_subtype: String
    var clothe_type: String
    var clothe_favorite: Bool
    
    public init(json: JSON) {
        self.clothe_colors = json["clothe_colors"].stringValue
        self.clothe_litteralColor = json["clothe_litteralColor"].stringValue
        self.clothe_cut = json["clothe_cut"].stringValue
        self.clothe_id = json["clothe_id"].stringValue
        self.clothe_image =  json["clothe_image"].stringValue
        self.clothe_isUnis = json["clothe_isUnis"].boolValue
        self.clothe_name = json["clothe_name"].stringValue
        self.clothe_partnerid = json["clothe_partnerid"].numberValue
        self.clothe_partnerName = json["clothe_partnerName"].stringValue
        self.clothe_pattern = json["clothe_pattern"].stringValue
        self.clothe_subtype = json["clothe_subtype"].stringValue
        self.clothe_type = json["clothe_type"].stringValue
        self.clothe_favorite = json["clothe_favorite"].boolValue
    }

}

public class Outfit: NSObject{
    var matchingRate: NSNumber
    var outfit: [ClotheModel]
    var style: String
    
    public init(json: JSON){
        self.matchingRate = json["matchingRate"].numberValue
        self.style = json["style"].stringValue
        self.outfit = [ClotheModel]()
        for (var i = 0; i < json["outfit"].arrayValue.count; i++){
            self.outfit.append(ClotheModel(json: json["outfit"][i]))
        }
    }
}