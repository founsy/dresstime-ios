//
//  Profil.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import CoreData

class Profil: NSManagedObject {

    @NSManaged var userid: String
    @NSManaged var access_token: String
    @NSManaged var refresh_token: String
    @NSManaged var expire_in: NSNumber
    @NSManaged var name: String
    @NSManaged var gender: String
    @NSManaged var temp_unit: String

}
