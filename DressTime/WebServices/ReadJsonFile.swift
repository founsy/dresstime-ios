//
//  ReadJsonFile.swift
//  DressTime
//
//  Created by Fab on 07/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class ReadJsonFile {
    
    func readFile(fileName: String) -> NSData? {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                return jsonData
            }
        }
        return nil
    }
}