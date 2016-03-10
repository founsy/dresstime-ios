//
//  DressingSynchro.swift
//  DressTime
//
//  Created by Fab on 20/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

protocol DressingSynchroDelegate {
    func dressingSynchro(dressingSynchro: DressingSynchro, syncDidFinish isFinish: Bool)
    func dressingSynchro(dressingSynchro: DressingSynchro, synchingProgressing currentValue: Int, totalNumber: Int)
}

class DressingSynchro {

    private var
    userId:String,
    clothesLocal: [Clothe]!,
    clothesStored: [String]!
    
    var delagate: DressingSynchroDelegate?
    
    init(userId: String){
        self.userId = userId
    }
    
    func execute(completion: (isNeeded: Bool) -> Void){
        if (isDressingEmpty()){
            if (Mock.isMockable()){
                updateMockableLocalstorage()
            } else {
                
                self.updateLocalStorage({ (isFinish) -> Void in
                    self.downloadImage()
                })
            }
            completion(isNeeded: true)
        } else {
            completion(isNeeded: false)
            isDressingBackup({ () -> () in
                self.diffBetweenBackEnd();
            }())
        }
    }
    
    private func isDressingEmpty() -> Bool {
        //Check if dressing locally is empty
        let dal = ClothesDAL()
        self.clothesLocal = dal.fetch()

        return (self.clothesLocal.count == 0)
    }
    
    private func isDressingBackup(getCompleted: ()){
        //Check if a backup dressing exist on server-side
        DressingService().GetClothesIdDressing { (isSuccess, object) -> Void in
            //self.clothesStored = object
            getCompleted
        }
    }
    
    
    private func diffBetweenBackEnd(){
        //Compare id from back-end vs DAL
        
        //Back-end is master
    }
    
    //Update Local DataBase
    //TODO - Need To update - 1 Call by Clothe too much
  /*  private func updateLocalStorage(){
        let dressingSvc = DressingService()
         var numberSync = 0
         dressingSvc.GetClothesIdDressing { (isSuccess, object) -> Void in
            if (isSuccess){
                let clotheDAL = ClothesDAL()
                for (var i = 0; i < object.arrayValue.count; i++) {
                    let id = object.arrayValue[i]["id"].stringValue
                    dressingSvc.GetClothe(id, completion: { (succeeded, clothe) -> () in
                        if (succeeded) {
                            let image: String = clothe["clothe_image"].stringValue
                            let data: NSData = NSData(base64EncodedString: image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                            let isUnis = clothe["clothe_isUnis"].boolValue
                            
                            clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: data, colors: clothe["clothe_colors"].stringValue)
                            numberSync++
                        }
                        if (numberSync >= object.arrayValue.count){
                            if let del = self.delagate{
                                del.syncDidFinish()
                            }
                        }
                    })
                }
                if (object.arrayValue.count == 0){
                    if let del = self.delagate{
                        del.syncDidFinish()
                    }

                }
            } /*else {
                if let del = self.delagate{
                    del.syncDidFinish()
                }
            }*/
        }
    } */
    
    private func updateLocalStorage(completion: (isNeeded: Bool) -> Void){
        let dressingSvc = DressingService()
        dressingSvc.GetDressing { (isSuccess, object) -> Void in
            if (isSuccess){
                let clotheDAL = ClothesDAL()
                for (var i = 0; i < object.arrayValue.count; i++) {
                    let clothe = object.arrayValue[i]
                    let isUnis = clothe["clothe_isUnis"].boolValue
                
                    clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: nil, colors: clothe["clothe_colors"].stringValue)
                }
                completion(isNeeded: true)
            }
        }
    }
    
    private func downloadImage(){
        let clotheDAL = ClothesDAL()
        let dressingSvc = DressingService()
        let clothes = clotheDAL.fetch()
        var numberSync = 0
        for (var i = 0; i < clothes.count; i++){
            dressingSvc.GetImageClothe(clothes[i].clothe_id, completion: { (isSuccess, object) -> Void in
                if (isSuccess){
                    clotheDAL.updateClotheImage(object["clothe_id"].stringValue, imageBase64: object["clothe_image"].stringValue)
                    numberSync++
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
    
    private func updateMockableLocalstorage(){
        if let nsdata = ReadJsonFile().readFile(SharedData.sharedInstance.currentUserId!){
            let json = JSON(data: nsdata)
            let clotheDAL = ClothesDAL()
            
            for (_, clothe) in json {   
                let image: String = clothe["clothe_image"].stringValue
                let data: NSData = NSData(base64EncodedString: image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                let isUnis = clothe["clothe_isUnis"].boolValue
                
                clotheDAL.save(clothe["clothe_id"].stringValue, partnerId: clothe["clothe_partnerid"].floatValue, partnerName: clothe["clothe_partnerName"].stringValue, type: clothe["clothe_type"] .stringValue, subType: clothe["clothe_subtype"].stringValue, name: clothe["clothe_name"].stringValue , isUnis: isUnis, pattern: clothe["clothe_pattern"].stringValue, cut: clothe["clothe_cut"].stringValue, image: data, colors: clothe["clothe_colors"].stringValue)
            }
            
            if let del = self.delagate{
               del.dressingSynchro(self, syncDidFinish: true)
            }
        }
    }


}