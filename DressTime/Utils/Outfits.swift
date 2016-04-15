//
//  Outfits.swift
//  DressTime
//
//  Created by Fab on 22/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

public class Outfit: NSObject{
    var matchingRate: NSNumber
    var clothes: [ClotheModel]
    var style: String
    var isSuggestion: Bool
    var isPutOn: Bool
    var updatedDate : NSDate?
    var moment: String?
    var _id: String
    
    public init(json: JSON){
        self._id = json["_id"].stringValue
        self.matchingRate = json["matchingRate"].numberValue
        self.style = json["style"].stringValue
        self.isSuggestion = json["isSuggestion"].bool != nil ? json["isSuggestion"].boolValue : true
        self.isPutOn = json["isPutOn"].bool != nil ? json["isPutOn"].boolValue : false
        self.moment = json["moment"].stringValue
        if let update = json["updated"].string {
            self.updatedDate = NSDate(dateString: update)
        }
        
        self.clothes = [ClotheModel]()
        if (json["outfit"].arrayValue.count > 0) {
            for (var i = 0; i < json["outfit"].arrayValue.count; i += 1){
                self.clothes.append(ClotheModel(json: json["outfit"][i]))
            }
        } else if (json["clothes"].arrayValue.count > 0) {
            for (var i = 0; i < json["clothes"].arrayValue.count; i += 1){
                self.clothes.append(ClotheModel(json: json["clothes"][i]))
            }
        }
    }
    
    public init(clothes: [ClotheModel], updatedDate: NSDate, isSuggestion: Bool, isPutOn: Bool){
        self._id = ""
        self.matchingRate = 0
        self.style = ""
        self.isSuggestion = isSuggestion
        self.isPutOn = isPutOn
        self.moment = ""
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
}

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let d = dateStringFormatter.dateFromString(dateString) {
            self.init(timeInterval:0, sinceDate:d)
        } else {
            self.init(timeIntervalSince1970: 0)
        }
    }
}