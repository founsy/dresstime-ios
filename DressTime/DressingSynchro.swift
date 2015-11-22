//
//  DressingSynchro.swift
//  DressTime
//
//  Created by Fab on 20/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

protocol DressingSynchroDelegate {
    func syncDidFinish()
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
                updateLocalStorage()
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
    private func updateLocalStorage(){
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
        }
    }


}