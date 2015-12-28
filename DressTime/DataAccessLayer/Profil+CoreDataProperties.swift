//
//  Profil+CoreDataProperties.swift
//  DressTime
//
//  Created by Fab on 27/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Profil {

    @NSManaged var access_token: String?
    @NSManaged var atWorkStyle: String?
    @NSManaged var email: String?
    @NSManaged var expire_in: NSNumber?
    @NSManaged var gender: String?
    @NSManaged var name: String?
    @NSManaged var numberPts: NSNumber?
    @NSManaged var onPartyStyle: String?
    @NSManaged var picture: NSData?
    @NSManaged var refresh_token: String?
    @NSManaged var relaxStyle: String?
    @NSManaged var temp_unit: String?
    @NSManaged var userid: String?
    @NSManaged var fb_id: String?
    @NSManaged var fb_token: String?
    @NSManaged var picture_url: String?

}
