//
//  Outfits.swift
//  DressTime
//
//  Created by Fab on 22/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ClotheType : String {
    case maille = "maille"
    case top = "top"
    case dress = "dress"
    case pants = "pants"
}

enum ClotheOrder : Int {
    case maille = 0
    case top = 1
    case dress = 2
    case pants = 3
}

open class Outfit: NSObject{
    var matchingRate: NSNumber
    var clothes: [ClotheModel]
    var style: String
    var isSuggestion: Bool
    var isPutOn: Bool
    var updatedDate : Date?
    var _id: String
    
    public init(json: JSON){
        self._id = json["_id"].stringValue
        self.matchingRate = json["matchingRate"].numberValue
        self.style = json["style"].stringValue
        self.isSuggestion = json["isSuggestion"].bool != nil ? json["isSuggestion"].boolValue : true
        self.isPutOn = json["isPutOn"].bool != nil ? json["isPutOn"].boolValue : false
        if let update = json["updated"].string {
            self.updatedDate = Date(dateString: update)
        }
        
        self.clothes = [ClotheModel]()
        if (json["outfit"].arrayValue.count > 0) {
            for clothe in json["outfit"].arrayValue {
                self.clothes.append(ClotheModel(json: clothe))
            }
        } else if (json["clothes"].arrayValue.count > 0) {
            for clothe in json["clothes"].arrayValue {
                self.clothes.append(ClotheModel(json: clothe))
            }
        }
    }
    
    public init(clothes: [ClotheModel], updatedDate: Date, isSuggestion: Bool, isPutOn: Bool){
        self._id = ""
        self.matchingRate = 0
        self.style = ""
        self.isSuggestion = isSuggestion
        self.isPutOn = isPutOn
        self.updatedDate = updatedDate
        self.clothes = clothes
    }
    
    func toDictionnary() -> NSDictionary {
        var dict = [NSDictionary]()
        for item in self.clothes {
            dict.append(item.toDictionnary())
        }
        
        let dictionnary = NSMutableDictionary()
        dictionnary["matchingRate"] = self.matchingRate
        dictionnary["style"] = self.style
        dictionnary["isSuggestion"] = self.isSuggestion
        dictionnary["isPutOn"] = self.isPutOn
        dictionnary["_id"] = self._id
        dictionnary["clothes"] = dict
        if let date = self.updatedDate {
            dictionnary["updated"] = date.toS("yyyy-MM-dd'T'HH:mm:ss.SSSZ")!
            
        }
        
        return dictionnary
    }
    
    func getOrder(_ type: String) -> Int {
        if type.isEmpty {
            return 0
        }
        switch ClotheType(rawValue: type)! {
        case ClotheType.maille :
            return ClotheOrder.maille.rawValue
        case ClotheType.top :
               return ClotheOrder.top.rawValue
        case ClotheType.dress :
            return ClotheOrder.dress.rawValue
        case ClotheType.pants :
            return ClotheOrder.pants.rawValue
        }
    }
    
    func orderOutfit() {
        var clothes = self.clothes
        clothes.sort { (clothe1, clothe2) -> Bool in
            getOrder(clothe1.clothe_type) < getOrder(clothe2.clothe_type)
        }
        self.clothes = clothes
    }
}
