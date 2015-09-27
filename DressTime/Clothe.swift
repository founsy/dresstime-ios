//
//  Clothe.swift
//  DressTime
//
//  Created by Fab on 02/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import CoreData

class Clothe: NSManagedObject {

    @NSManaged var clothe_colors: String
    @NSManaged var clothe_cut: String
    @NSManaged var clothe_id: String
    @NSManaged var clothe_image: NSData
    @NSManaged var clothe_isUnis: NSNumber
    @NSManaged var clothe_name: String
    @NSManaged var clothe_partnerid: NSNumber
    @NSManaged var clothe_partnerName: String
    @NSManaged var clothe_pattern: String
    @NSManaged var clothe_subtype: String
    @NSManaged var clothe_type: String
    @NSManaged var profilRel: Profil
    
    func toDictionnary() -> NSDictionary {
        let attributes = Array(self.entity.attributesByName.keys)
        let dict = self.dictionaryWithValuesForKeys(attributes)
        return dict ;
    }
}
