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
    
    
    func save(clotheId: String, partnerId: NSNumber, partnerName: String, type: String, subType: String, name: String, isUnis: Bool, pattern: String, cut: String, image: NSData, colors: String){
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
        clothe.profilRel = profilDal.fetch(SharedData.sharedInstance.currentUserId!)!
        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
    }
    
    func update(clothe: Clothe){
        do {
            try clothe.managedObjectContext?.save()
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