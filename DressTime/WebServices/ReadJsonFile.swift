//
//  ReadJsonFile.swift
//  DressTime
//
//  Created by Fab on 07/10/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation

class ReadJsonFile {
    
    func readFile(_ fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                return jsonData
            }
        }
        return nil
    }
}
