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
    var sexe: String? = "M"
    
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
                return ["jumper-fin","jumper-epais","cardigan","sweater"]
            case "Top":
                return ["shirt", "shirt-sleeve", "polo-sleeve", "polo", "tshirt"]
            case "Pants":
                return ["jeans", "jeans-slim", "trousers-pleated", "trousers-suit", "chinos", "trousers-regular", "trousers", "trousers-slim", "bermuda", "short"]
            case "Dress":
                return ["skirts-midlenght", "skirts-long", "skirts-short", "dress-casual", "dress-evening", "dress-straight"]
            default:
                return []
        }
    }
    
    func subTypeToImage(subtype: String) -> String {
        switch subtype {
            case "jumper-fin":
                return "jumperThin"
            case "jumper-epais":
                return "jumper"
            case "cardigan":
                return "cardigan"
            case "sweater":
                return "pull"
            case "tshirt":
                return "tshirt"
            case "shirt":
                return "shirtLong"
            case "shirt-sleeve":
                return "shirtSleeve"
            case "polo":
                return "poloLong"
            case "polo-sleeve":
                return "polo"
            case "jeans":
                return "jean"
            case "jeans-slim":
                return "jeanSkinny"
            case "trousers-pleated":
                return "pantsDarts"
            case "trousers-suit":
                return "pantsSuit"
            case "chinos":
                return "pantsChino"
            case "trousers-regular":
                return "pants2"
            case "trousers":
                return "pants"
            case "trousers-slim":
                return "pantsSlim"
            case "bermuda":
                return "bermuda"
            case "short":
                return "shortJean"
            case "skirts-midlenght":
                return "skirt2"
            case "skirts-long":
                return "skirt1"
            case "skirts-short":
                return "skirt3"
            case "dress-casual":
                return "dress2"
            case "dress-evening":
                return "dress"
            case "dress-straight":
                return "dress"
        default:
                return ""
        
        }
    }
}