//
//  PListReader.swift
//  DressTime
//
//  Created by Fab on 21/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class PListReader {
    
    static func getStringProperty(_ key: String) -> String {
        let path = Bundle.main.path(forResource: "DressTime", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        return dict!.value(forKey: key) as! String
    }

}
