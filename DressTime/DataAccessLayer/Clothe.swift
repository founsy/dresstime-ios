//
//  Clothe.swift
//  DressTime
//
//  Created by Fab on 02/08/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Clothe: NSManagedObject {

    @NSManaged var clothe_colors: String
    @NSManaged var clothe_litteralColor: String
    @NSManaged var clothe_cut: String
    @NSManaged var clothe_id: String
    @NSManaged var clothe_image: NSData?
    @NSManaged var clothe_isUnis: NSNumber
    @NSManaged var clothe_name: String
    @NSManaged var clothe_partnerid: NSNumber
    @NSManaged var clothe_partnerName: String
    @NSManaged var clothe_pattern: String
    @NSManaged var clothe_subtype: String
    @NSManaged var clothe_type: String
    @NSManaged var clothe_favorite: Bool
    @NSManaged var profilRel: Profil
    
    func toDictionnary() -> NSDictionary {
        let attributes = Array(self.entity.attributesByName.keys)
        let dict = self.dictionaryWithValuesForKeys(attributes)
        return dict ;
    }
    
    func getImage() -> UIImage {
        if let image = UIImage(contentsOfFile: FileManager.getDocumentsDirectory().stringByAppendingPathComponent("\(self.clothe_id).png")){
            return image
        }
        /*if let img = self.clothe_image {
            if let uiimage = UIImage(data: img) {
                return uiimage
            }
        } */
        
        var named = ""
        switch(self.clothe_type){
        case "maille":
            named = "TypeMailleIcon"
        case "top":
            named = "TypeTopIcon"
        case "pants":
            named = "TypePantsIcon"
        case "dress":
            named = "TypeDressIcon"
        default:
            named = "TypeTopIcon"
        }
        return UIImage(named: named)!
    }
}
