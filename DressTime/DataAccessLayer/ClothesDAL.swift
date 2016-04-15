//
//  ClothesDAL.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//
import UIKit
import Foundation
import CoreData

class ClothesDAL {
    
    var managedObjectContext: NSManagedObjectContext
    
    init(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
    }
    
    func fetch(type type: String) -> [Clothe]{
        var clothes  = [Clothe]()
        if let userId = SharedData.sharedInstance.currentUserId {
            let fetchRequest = NSFetchRequest(entityName: "Clothe")
            let predicate = NSPredicate(format: "clothe_type = %@ AND profilRel.userid = %@", type, userId)
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            do {
                clothes = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Clothe]
            } catch let error as NSError {
                print(error)
            }
        }
        return clothes
    }
    
    func fetch(clotheId: String) -> Clothe? {
        let fetchRequest = NSFetchRequest(entityName: "Clothe")
        let predicate = NSPredicate(format: "clothe_id = %@", clotheId)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        do {
            if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Clothe] {
                if (fetchResults.count > 0){
                    return fetchResults[0]
                } else {
                    return nil
                }
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    func fetch() -> [Clothe]{
        let fetchRequest = NSFetchRequest(entityName: "Clothe")
        let predicate = NSPredicate(format: "profilRel.userid = %@", SharedData.sharedInstance.currentUserId!)
        fetchRequest.predicate = predicate
        do {
            if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Clothe] {
                return fetchResults
            }
        } catch let error as NSError {
            print(error)
        }
        return [Clothe]()
    }
    
    func numberOfClothes() -> Int {
        if let userId = SharedData.sharedInstance.currentUserId {
            let fetchRequest = NSFetchRequest(entityName: "Clothe")
            let predicate = NSPredicate(format: "profilRel.userid = %@", userId)
            fetchRequest.predicate = predicate
            do {
                if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Clothe] {
                    return fetchResults.count
                }
            } catch let error as NSError {
                print(error)
                return 0
            }
            return 0
        }
        return 0
    }
    
    func delete(clothe: Clothe) {
        // Delete it from the managedObjectContext
        self.managedObjectContext.deleteObject(clothe)
    
        do {
            try managedObjectContext.save()
             NSLog("Clothe Deleted");
        } catch let error as NSError {
            print(error)
        }
    }
    
    func save(clotheToSave: NSDictionary) -> Clothe{
        let entityDescription = NSEntityDescription.entityForName("Clothe", inManagedObjectContext: managedObjectContext);
        let clothe = Clothe(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        let profilDal = ProfilsDAL()
        
        clothe.clothe_id = NSUUID().UUIDString
        clothe.clothe_partnerid = clotheToSave["clothe_partnerid"] as! NSNumber
        clothe.clothe_partnerName = clotheToSave["clothe_partnerName"] as! String
        clothe.clothe_type = clotheToSave["clothe_type"] as! String
        clothe.clothe_subtype = clotheToSave["clothe_subtype"] as! String
        clothe.clothe_name = clotheToSave["clothe_name"] as! String
        clothe.clothe_isUnis = clotheToSave["clothe_isUnis"] as! Bool
        clothe.clothe_pattern = clotheToSave["clothe_pattern"] as! String
        clothe.clothe_cut = clotheToSave["clothe_cut"] as! String
        clothe.clothe_image = clotheToSave["clothe_image"] as? NSData
        clothe.clothe_colors = clotheToSave["clothe_colors"] as! String
        clothe.clothe_litteralColor = clotheToSave["clothe_litteralColor"] as! String
        clothe.profilRel = profilDal.fetch(SharedData.sharedInstance.currentUserId!)!
        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
        return clothe
    }
    
    func save(clotheId: String, partnerId: NSNumber, partnerName: String, type: String, subType: String, name: String, isUnis: Bool, pattern: String, cut: String, image: NSData?, colors: String) -> Clothe {
        let entityDescription = NSEntityDescription.entityForName("Clothe", inManagedObjectContext: managedObjectContext);
        let clothe = Clothe(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        let profilDal = ProfilsDAL()
        
        clothe.clothe_id = clotheId
        clothe.clothe_partnerid = partnerId
        clothe.clothe_partnerName = partnerName
        clothe.clothe_type = type
        clothe.clothe_subtype = subType
        clothe.clothe_name = name
        clothe.clothe_isUnis = isUnis
        clothe.clothe_pattern = pattern
        clothe.clothe_cut = cut
        clothe.clothe_image = image
        clothe.clothe_colors = colors
        let hexTranslator = HexColorToName()
        let colorName = UIColor.colorWithHexString(clothe.clothe_colors)
        clothe.clothe_litteralColor = hexTranslator.name(colorName)[1] as! String
        clothe.profilRel = profilDal.fetch(SharedData.sharedInstance.currentUserId!)!
        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
        return clothe
    }
    
    func update(clothe: Clothe){
        do {
            try clothe.managedObjectContext?.save()
        } catch let error as NSError {
          NSLog(error.localizedFailureReason!);
        }
    }
    
    func updateClotheImage(clotheId: String, imageBase64: String){
        let fetchRequest = NSFetchRequest(entityName: "Clothe")
        let predicate = NSPredicate(format: "clothe_id = %@", clotheId)
   
        let data: NSData = NSData(base64EncodedString: imageBase64, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)!
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        do {
            if let fetchResult = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Clothe] {
                if (fetchResult.count > 0){
                    fetchResult[0].clothe_image = data
                }
            }
        } catch let error as NSError {
            print(error)
        }
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
    }
    
    func updateClotheId(){
        let fetchRequest = NSFetchRequest(entityName: "Clothe")
        do {
            if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Clothe] {
                for clothe in fetchResults {
                    clothe.clothe_id = NSUUID().UUIDString
                }
            }
        } catch let error as NSError {
            print(error)
        }
        do {
            try managedObjectContext.save()
              NSLog("Contact Saved");
        } catch let error as NSError {
             NSLog(error.localizedFailureReason!);
        }
    }

}