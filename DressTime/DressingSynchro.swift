//
//  DressingSynchro.swift
//  DressTime
//
//  Created by Fab on 20/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation

class DressingSynchro {

    private var
    userId:String,
    clothesLocal: [Clothe]!,
    clothesStored: [String]!
    
    init(userId: String){
        self.userId = userId
    }
    
    func execute(){
        if (isDressingEmpty()){
            updateLocalStorage()
        } else {
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
        DressTimeService.getClothesIdDressing(self.userId, clotheCompleted: { (succeeded, msg) -> () in
            self.clothesStored = msg
            getCompleted
        })
    }
    
    
    private func diffBetweenBackEnd(){
        //Compare id from back-end vs DAL
        
        //Back-end is master
    }
    
    //Update Local DataBase
    //TODO - Need To update - 1 Call by Clothe too much
    private func updateLocalStorage(){
        DressTimeService.getClothesIdDressing(self.userId, clotheCompleted: { (succeeded, msg) -> () in
            self.clothesStored = msg
            
            let clotheDAL = ClothesDAL()
                for id in self.clothesStored {
                DressTimeService.getClothe(self.userId, clotheId: id, clotheCompleted: { (succeeded, msg) -> () in
                    println(msg)
                    let clothe: AnyObject = msg
                        var image: String = clothe["clothe_image"] as! String
                        var data: NSData = NSData(base64EncodedString: image, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
                        
                        clotheDAL.save(clothe["clothe_id"] as! String, partnerId: clothe["clothe_partnerid"] as! NSNumber, partnerName: clothe["clothe_partnerName"] as! String, type: clothe["clothe_type"] as! String, subType: clothe["clothe_subtype"] as! String, name: clothe["clothe_name"] as! String, isUnis: clothe["clothe_isUnis"] as! Bool, pattern: clothe["clothe_pattern"] as! String, cut: clothe["clothe_cut"] as! String, image: data, colors: clothe["clothe_colors"] as! String)

                })
            
            }
        })
    }
    
    
}