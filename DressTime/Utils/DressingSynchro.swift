//
//  DressingSynchro.swift
//  DressTime
//
//  Created by Fab on 20/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol DressingSynchroDelegate {
    func dressingSynchro(_ dressingSynchro: DressingSynchro, syncDidFinish isFinish: Bool)
    func dressingSynchro(_ dressingSynchro: DressingSynchro, synchingProgressing currentValue: Int, totalNumber: Int)
}

class DressingSynchro {

    fileprivate var
    userId:String,
    clothesLocal: [Clothe]!,
    clothesStored: [String]!
    
    var delagate: DressingSynchroDelegate?
    
    init(userId: String){
        self.userId = userId
    }
    
    func execute(_ completion: (_ isNeeded: Bool) -> Void){
        if (isDressingEmpty()){
            if (Mock.isMockable()){
                updateMockableLocalstorage()
            } else {
                
                self.updateLocalStorage({ (isFinish) -> Void in
                    self.downloadImage()
                })
            }
            completion(true)
        } else {
            completion(false)
            isDressingBackup({ () -> () in
                self.diffBetweenBackEnd();
            }())
        }
    }
    
    fileprivate func isDressingEmpty() -> Bool {
        //Check if dressing locally is empty
        let dal = ClothesDAL()
        self.clothesLocal = dal.fetch()

        return (self.clothesLocal.count == 0)
    }
    
    fileprivate func isDressingBackup(_ getCompleted: ()){
        //Check if a backup dressing exist on server-side
        DressingService().GetClothesIdDressing { (isSuccess, object) -> Void in
            //self.clothesStored = object
            getCompleted
        }
    }
    
    
    fileprivate func diffBetweenBackEnd(){
        //Compare id from back-end vs DAL
        
        //Back-end is master
    }
    
    
    fileprivate func updateLocalStorage(_ completion: @escaping (_ isNeeded: Bool) -> Void){
        let dressingSvc = DressingService()
        dressingSvc.GetDressing { (isSuccess, object) -> Void in
            if (isSuccess){
                let clotheDAL = ClothesDAL()
                for i in 0 ..< object.arrayValue.count {
                    let clothe = object.arrayValue[i]
                    let isUnis = clothe["clothe_isUnis"].boolValue
                
                    _ = clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: nil, colors: clothe["clothe_colors"].stringValue)
                }
                completion(true)
            }
        }
    }
    
    fileprivate func downloadImage(){
        let clotheDAL = ClothesDAL()
        let dressingSvc = DressingService()
        let clothes = clotheDAL.fetch()
        var numberSync = 0
        for i in 0 ..< clothes.count {
            dressingSvc.GetImageClothe(clothes[i].clothe_id, completion: { (isSuccess, object) -> Void in
                if (isSuccess){
                    _ = FileManager.saveImage("\(object["clothe_id"].stringValue).png", imageBase64: object["clothe_image"].stringValue)
                    //clotheDAL.updateClotheImage(object["clothe_id"].stringValue, imageBase64: object["clothe_image"].stringValue)
                    numberSync += 1
                    if let del = self.delagate{
                        del.dressingSynchro(self, synchingProgressing: numberSync, totalNumber: clothes.count)
                    }
                }
                if (numberSync >= clothes.count){
                    if let del = self.delagate{
                        del.dressingSynchro(self, syncDidFinish: true)
                    }
                }
            })
        }
        if (clothes.count == 0){
            if let del = self.delagate{
                del.dressingSynchro(self, syncDidFinish: true)
            }
        }
    }
    
    func migrateImageCoreDataToFile(){
        let clotheDAL = ClothesDAL()
        let clothes = clotheDAL.fetch()
        
        for item in clothes {
            if let data = item.clothe_image {
                _ = FileManager.saveImage(item.clothe_id, data: data)
                item.clothe_image = nil
                clotheDAL.update(item)
            }
        }
    }
    
    fileprivate func updateMockableLocalstorage(){
        if let nsdata = ReadJsonFile().readFile(SharedData.sharedInstance.currentUserId!){
            let json = JSON(data: nsdata)
            let clotheDAL = ClothesDAL()
            
            for (_, clothe) in json {   
                let image: String = clothe["clothe_image"].stringValue
                let data: Data = Data(base64Encoded: image, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                let isUnis = clothe["clothe_isUnis"].boolValue
                
                _ = clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: data, colors: clothe["clothe_colors"].stringValue)
            }
            
            if let del = self.delagate{
               del.dressingSynchro(self, syncDidFinish: true)
            }
        }
    }


}
