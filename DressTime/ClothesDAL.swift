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
        self.managedObjectContext = appDelegate.managedObjectContext!
    }
    
    func fetch(type: String) -> [Clothe]{
        var clothes  = [Clothe]() // Where Locations = your NSManaged Class
        
        var fetchRequest = NSFetchRequest(entityName: "Clothe")
        let predicate = NSPredicate(format: "clothe_type = %@", type)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        clothes = self.managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as! [Clothe]
        
        
        return clothes
    }
    
    func fetch() -> [Clothe]{
        
        var fetchedResultsController: NSFetchedResultsController?
        var fetchRequest = NSFetchRequest(entityName: "Clothe")
        if let fetchResults = self.managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Clothe] {
            return fetchResults
        }
        return [Clothe]()
    }
    
    func delete(clothe: Clothe) {
        // Delete it from the managedObjectContext
        self.managedObjectContext.deleteObject(clothe)
        var error: NSError?
        managedObjectContext.save(&error)
        
        if let err = error {
            NSLog(err.localizedFailureReason!);
        } else {
            NSLog("Clothe Deleted");
        }

    }
    
    
    func save(partnerId: NSNumber, partnerName: String, type: String, subType: String, name: String, isUnis: Bool, pattern: String, cut: String, image: NSData, colors: String){
        let entityDescription = NSEntityDescription.entityForName("Clothe", inManagedObjectContext: managedObjectContext);
        let clothe = Clothe(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
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
        
        var error: NSError?
        managedObjectContext.save(&error)
        
        if let err = error {
            NSLog(err.localizedFailureReason!);
        } else {
            NSLog("Contact Saved");
        }
    }


}