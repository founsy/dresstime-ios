//
//  SharedData.swift
//  DressTime
//
//  Created by Fab on 02/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

class SharedData {
    static let sharedInstance = SharedData()
    
    var currentUserId: String?
    var sexe: String?
    
    var weatherCode: String?
    var lowTemp: String?
    var highTemp: String?
    var city: String?
    
    func getType(gender: String) -> [String]{
        if (gender == "M"){
            return ["Maille","Top", "Pants"]
        } else {
            return ["Maille","Top", "Pants", "Dress"]
        }
    }
    
    func getSubType(type: String) -> [String] {
        switch type {
            case "Maille":
                return ["jumper-fin","jumper-epais ","cardigan","sweater"]
            case "Top":
                return ["tshirt", "shirt", "shirt-sleeve", "polo","polo-sleeve"]
            case "Pants":
                return ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
            case "Dress":
                return ["skirt"]
            default:
                return []
        }
    }
}