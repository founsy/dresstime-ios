//
//  DownloadImageManager.swift
//  DressTime
//
//  Created by Fab on 28/12/2015.
//  Copyright © 2015 Fab. All rights reserved.
//

import Foundation


class DownloadImageManager {
    
    func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void)) {
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error)
            })
    }
    
  /*  func downloadImage(url: NSURL){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                imageURL.image = UIImage(data: data)
            }
        }
    } */

}
