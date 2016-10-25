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
            self.updateLocalStorage({ (isFinish) -> Void in
                self.downloadImage()
            })

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
        let dressTimeClient = DressTimeClient()
        dressTimeClient.fetchClothesIdWithCompletion { (result) in
            switch result {
            case .success(_):
                getCompleted
            case .failure(let error):
                print("\(#function) Error: \(error)")
            }
        }
    }
    
    
    fileprivate func diffBetweenBackEnd(){
        //Compare id from back-end vs DAL
        
        //Back-end is master
    }
    
    
    fileprivate func updateLocalStorage(_ completion: @escaping (_ isNeeded: Bool) -> Void){
        let dressTimeClient = DressTimeClient()
        dressTimeClient.fetchDressingWithCompletion(withCompletion: { (result) in
            switch result {
                case .success(let json):
                    let clotheDAL = ClothesDAL()
                    for clothe in json.arrayValue {
                        let isUnis = clothe["clothe_isUnis"].boolValue
                        
                        _ = clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: nil, colors: clothe["clothe_colors"].stringValue)
                    }
                    completion(true)
                case .failure(let error):
                print("\(#function) Error: \(error)")
                completion(false)
            }
        })
    }
    
    fileprivate func downloadImage(){
        let clotheDAL = ClothesDAL()
        let dressTimeClient = DressTimeClient()
        let clothes = clotheDAL.fetch()
        var numberSync = 0
        
        for clothe in clothes {
            dressTimeClient.fetchClotheImageWithCompletion(for: clothe.clothe_id, withCompletion: { (result) in
                switch result {
                case .success(let json):
                    _ = FileManager.saveImage("\(json["clothe_id"].stringValue).png", imageBase64: json["clothe_image"].stringValue)
                    numberSync += 1
                    if let del = self.delagate{
                        del.dressingSynchro(self, synchingProgressing: numberSync, totalNumber: clothes.count)
                    }
                    
                    if (numberSync >= clothes.count){
                        if let del = self.delagate{
                            del.dressingSynchro(self, syncDidFinish: true)
                        }
                    }
                    
                case .failure(let error):
                    print("\(#function) Error: \(error)")
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
}
