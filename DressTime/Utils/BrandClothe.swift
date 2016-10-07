//
//  BrandClothe.swift
//  DressTime
//
//  Created by Fab on 24/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON

open class BrandClothe: ClotheModel{
    var clothe_brand: String?
    var clothe_brandLogo: String?
    var clothe_price: NSNumber
    var clothe_currency: String
    var clothe_shopUrl: String
    var clothe_sexe: String
    var clothes: [ClotheModel]
    
    public override init(json: JSON) {
        self.clothe_brand = json["brandClothe"]["clothe_brand"].stringValue
        self.clothe_brandLogo = json["brandClothe"]["clothe_brandLogo"].stringValue
        self.clothe_price = json["brandClothe"]["clothe_price"].numberValue
        self.clothe_currency = json["brandClothe"]["clothe_currency"].stringValue
        self.clothe_shopUrl = json["brandClothe"]["clothe_shopUrl"].stringValue
        self.clothe_sexe = json["brandClothe"]["clothe_sexe"].stringValue
        
        self.clothes = [ClotheModel]()
        
        for item in json["clothes"].arrayValue {
            self.clothes.append(ClotheModel(json: item["clothe"]))
        }
        
        super.init(json: json["brandClothe"])
    }

}
