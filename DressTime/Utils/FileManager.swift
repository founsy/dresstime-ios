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
    
    class func saveImage(name: String, image: UIImage) -> String? {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            let filename = getDocumentsDirectory().stringByAppendingPathComponent(name)
            data.writeToFile(filename, atomically: true)
            return filename
        }
        return nil
    }
    
    class func saveImage(name: String, data: NSData) -> String? {
        let filename = getDocumentsDirectory().stringByAppendingPathComponent(name)
        data.writeToFile(filename, atomically: true)
        return filename
    }
    
    class func saveImage(name: String, imageBase64: String) -> String? {
        if let data: NSData = NSData(base64EncodedString: imageBase64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) {
            let filename = getDocumentsDirectory().stringByAppendingPathComponent(name)
            data.writeToFile(filename, atomically: true)
            return filename
        }
        return nil
    }
    
    class func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}