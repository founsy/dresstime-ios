//
//  DressTimeBL.swift
//  DressTime
//
//  Created by Fab on 14/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class DressTimeBL {
    
    let orderingType = ["maille", "top", "dress", "pants"]
    
    enum ClotheType : String {
        case maille = "maille"
        case top = "top"
        case dress = "dress"
        case pants = "pants"
    }
    
    enum ClotheOrder : Int {
        case maille = 0
        case dress = 1
        case top = 2
        case pants = 3
    }
    
    static func getClotheOrder(withType type: String) -> Int {
        switch type {
        case ClotheType.maille.rawValue:
           return ClotheOrder.maille.rawValue
        case ClotheType.dress.rawValue:
            return ClotheOrder.dress.rawValue
        case ClotheType.top.rawValue:
            return ClotheOrder.top.rawValue
        case ClotheType.pants.rawValue:
            return ClotheOrder.pants.rawValue
        default:
            return -1
        }
    }
    
    func orderOutfit(_ outfit: Outfit) -> Outfit{
        var clothes = [ClotheModel]()
        
        for item in outfit.clothes {
            switch ClotheType(rawValue: item.clothe_type)! {
            case ClotheType.maille :
                clothes.insert(item, at: ClotheOrder.maille.rawValue)
                break
            case ClotheType.top :
                clothes.insert(item, at: ClotheOrder.top.rawValue)
                break
            case ClotheType.dress :
                clothes.insert(item, at: ClotheOrder.dress.rawValue - 1)
                break
            case ClotheType.pants :
                clothes.insert(item, at: ClotheOrder.pants.rawValue - 1)
                break
            }
        }
        outfit.clothes = clothes
        return outfit
    }
}
