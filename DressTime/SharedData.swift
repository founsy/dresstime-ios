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
    
    var weatherCode: String?
    var lowTemp: String?
    var highTemp: String?
    var city: String?

}