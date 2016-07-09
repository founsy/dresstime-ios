//
//  ClotheModel.swift
//  DressTime
//
//  Created by Fab on 24/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ClotheModel: NSObject {
    var id: String?
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
        self.id = json["_id"].stringValue
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
    
    init(clothe: Clothe) {
        self.clothe_colors = clothe.clothe_colors
        self.clothe_litteralColor = clothe.clothe_litteralColor
        self.clothe_cut = clothe.clothe_cut
        self.clothe_id = clothe.clothe_id
        self.clothe_image =  ""
        self.clothe_isUnis = clothe.clothe_isUnis as Bool
        self.clothe_name = clothe.clothe_name
        self.clothe_partnerid = clothe.clothe_partnerid
        self.clothe_partnerName = clothe.clothe_partnerName
        self.clothe_pattern = clothe.clothe_pattern
        self.clothe_subtype = clothe.clothe_subtype
        self.clothe_type = clothe.clothe_type
        self.clothe_favorite = clothe.clothe_favorite
    }
    
    func toDictionnary() -> NSDictionary {
        return [
            "_id" : (self.id != nil ? self.id : "")!,
            "clothe_colors" : self.clothe_colors,
            "clothe_litteralColor" : self.clothe_litteralColor,
            "clothe_id" : self.clothe_id,
            "clothe_image" : self.clothe_image,
            "clothe_isUnis" : self.clothe_isUnis,
            "clothe_name" : self.clothe_name,
            "clothe_partnerid" : self.clothe_partnerid,
            "clothe_partnerName" : self.clothe_partnerName,
            "clothe_pattern" :  self.clothe_pattern,
            "clothe_subtype" : self.clothe_subtype,
            "clothe_type" : self.clothe_type,
            "clothe_favorite" : self.clothe_favorite
        ]
    };
    
}