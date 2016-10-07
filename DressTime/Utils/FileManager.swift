//
//  FileManager.swift
//  DressTime
//
//  Created by Fab on 5/28/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class FileManager {
    
    class func saveImage(_ name: String, image: UIImage) -> String? {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            return filename
        }
        return nil
    }
    
    class func saveImage(_ name: String, data: Data) -> String? {
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
        return filename
    }
    
    class func saveImage(_ name: String, imageBase64: String) -> String? {
        if let data: Data = Data(base64Encoded: imageBase64, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
            return filename
        }
        return nil
    }
    
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
}
