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
        case top = 1
        case dress = 2
        case pants = 3
    }
    
    func orderOutfit(outfit: Outfit) -> Outfit{
        var clothes = [ClotheModel]()
        
        for item in outfit.clothes {
            switch ClotheType(rawValue: item.clothe_type)! {
            case ClotheType.maille :
                clothes.insert(item, atIndex: ClotheOrder.maille.rawValue)
                break
            case ClotheType.top :
                clothes.insert(item, atIndex: ClotheOrder.top.rawValue)
                break
            case ClotheType.dress :
                clothes.insert(item, atIndex: ClotheOrder.dress.rawValue - 1)
                break
            case ClotheType.pants :
                clothes.insert(item, atIndex: ClotheOrder.pants.rawValue - 1)
                break
            }
        }
        outfit.clothes = clothes
        return outfit
    }
}