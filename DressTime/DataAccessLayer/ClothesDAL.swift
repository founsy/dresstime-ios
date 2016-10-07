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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
    }
    
    func fetch(type: String) -> [Clothe]{
        var clothes  = [Clothe]()
        if let userId = SharedData.sharedInstance.currentUserId {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
            let predicate = NSPredicate(format: "clothe_type = %@ AND profilRel.userid = %@", type, userId)
            
            // Set the predicate on the fetch request
            fetchRequest.predicate = predicate
            
            do {
                clothes = try self.managedObjectContext.fetch(fetchRequest) as! [Clothe]
            } catch let error as NSError {
                print(error)
            }
        }
        return clothes
    }
    
    func fetch(_ clotheId: String) -> Clothe? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
        let predicate = NSPredicate(format: "clothe_id = %@", clotheId)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        do {
            if let fetchResults = try self.managedObjectContext.fetch(fetchRequest) as? [Clothe] {
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
        let predicate = NSPredicate(format: "profilRel.userid = %@", SharedData.sharedInstance.currentUserId!)
        fetchRequest.predicate = predicate
        do {
            if let fetchResults = try self.managedObjectContext.fetch(fetchRequest) as? [Clothe] {
                return fetchResults
            }
        } catch let error as NSError {
            print(error)
        }
        return [Clothe]()
    }
    
    func numberOfClothes() -> Int {
        if let userId = SharedData.sharedInstance.currentUserId {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
            let predicate = NSPredicate(format: "profilRel.userid = %@", userId)
            fetchRequest.predicate = predicate
            do {
                if let fetchResults = try self.managedObjectContext.fetch(fetchRequest) as? [Clothe] {
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
    
    func delete(_ clothe: Clothe) -> Bool {
        // Delete it from the managedObjectContext
        self.managedObjectContext.delete(clothe)
    
        do {
            try managedObjectContext.save()
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    func save(_ clotheToSave: NSDictionary) -> Clothe{
        let entityDescription = NSEntityDescription.entity(forEntityName: "Clothe", in: managedObjectContext);
        let clothe = Clothe(entity: entityDescription!, insertInto: managedObjectContext);
        
        let profilDal = ProfilsDAL()
        
        clothe.clothe_id = UUID().uuidString
        clothe.clothe_partnerid = clotheToSave["clothe_partnerid"] as! NSNumber
        clothe.clothe_partnerName = clotheToSave["clothe_partnerName"] as! String
        clothe.clothe_type = clotheToSave["clothe_type"] as! String
        clothe.clothe_subtype = clotheToSave["clothe_subtype"] as! String
        clothe.clothe_name = clotheToSave["clothe_name"] as! String
        clothe.clothe_isUnis = clotheToSave["clothe_isUnis"] as! Bool as NSNumber
        clothe.clothe_pattern = clotheToSave["clothe_pattern"] as! String
        clothe.clothe_cut = clotheToSave["clothe_cut"] as! String
        clothe.clothe_image = nil
        clothe.clothe_colors = clotheToSave["clothe_colors"] as! String
        clothe.clothe_litteralColor = clotheToSave["clothe_litteralColor"] as! String
        clothe.profilRel = profilDal.fetch(SharedData.sharedInstance.currentUserId!)!
        
        if let data = clotheToSave["clothe_image"] as? Data {
            _ = FileManager.saveImage("\(clothe.clothe_id).png", data: data)
        }
        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
        return clothe
    }
    
    func save(_ clotheId: String, partnerId: Float, partnerName: String, type: String, subType: String, name: String, isUnis: Bool, pattern: String, cut: String, image: Data?, colors: String) -> Clothe {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Clothe", in: managedObjectContext);
        let clothe = Clothe(entity: entityDescription!, insertInto: managedObjectContext);
        
        let profilDal = ProfilsDAL()
        
        clothe.clothe_id = clotheId
        clothe.clothe_partnerid = partnerId as NSNumber
        clothe.clothe_partnerName = partnerName
        clothe.clothe_type = type
        clothe.clothe_subtype = subType
        clothe.clothe_name = name
        clothe.clothe_isUnis = isUnis as NSNumber
        clothe.clothe_pattern = pattern
        clothe.clothe_cut = cut
        clothe.clothe_image = nil
        clothe.clothe_colors = colors
        let hexTranslator = HexColorToName()
        let colorName = UIColor.colorWithHexString(clothe.clothe_colors)
        clothe.clothe_litteralColor = hexTranslator.name(colorName)[1] as! String
        clothe.profilRel = profilDal.fetch(SharedData.sharedInstance.currentUserId!)!
        
        
        if let data = image {
            _ = FileManager.saveImage("\(clothe.clothe_id).png", data: data)
        }

        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
        }
        return clothe
    }
    
    func update(_ clothe: Clothe){
        do {
            try clothe.managedObjectContext?.save()
        } catch let error as NSError {
          NSLog(error.localizedFailureReason!);
        }
    }
    
    func updateClotheImage(_ clotheId: String, imageBase64: String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
        let predicate = NSPredicate(format: "clothe_id = %@", clotheId)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        do {
            if let fetchResult = try self.managedObjectContext.fetch(fetchRequest) as? [Clothe] {
                _ = FileManager.saveImage("\(clotheId).png", imageBase64: imageBase64)
                if (fetchResult.count > 0){
                    fetchResult[0].clothe_image = nil
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
        do {
            if let fetchResults = try self.managedObjectContext.fetch(fetchRequest) as? [Clothe] {
                for clothe in fetchResults {
                    clothe.clothe_id = UUID().uuidString
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
