//
//  ProfilsDAL.swift
//  DressTime
//
//  Created by Fab on 18/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit
import CoreData

class ProfilsDAL {

    var managedObjectContext: NSManagedObjectContext
    
    init(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
    }
    
    
    func fetch(userId: String) -> Profil? {
        var fetchedResultsController: NSFetchedResultsController?
        var fetchRequest = NSFetchRequest(entityName: "Profil")
        let predicate = NSPredicate(format: "userid = %@", userId)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        if let fetchResults = self.managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Profil] {
            if (fetchResults.count > 0){
                return fetchResults[0]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func fetch() -> Profil? {
        var fetchedResultsController: NSFetchedResultsController?
        var fetchRequest = NSFetchRequest(entityName: "Profil")
        if let fetchResults = self.managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [Profil] {
            if (fetchResults.count > 0){
                return fetchResults[0]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func save(userid: String, access_token: String, refresh_token: String, expire_in: Int, name: String, gender: String, temp_unit: String){
        let entityDescription = NSEntityDescription.entityForName("Profil", inManagedObjectContext: managedObjectContext);
        let profil = Profil(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        profil.userid = userid
        profil.access_token = access_token
        profil.refresh_token = refresh_token
        profil.expire_in = expire_in
        profil.name = name
        profil.gender = gender
        profil.temp_unit = temp_unit
        
        var error: NSError?
        managedObjectContext.save(&error)
        
        if let err = error {
            NSLog(err.localizedFailureReason!);
        } else {
            NSLog("Contact Saved");
        }
    }
    
    func update(profil: Profil) {
        if let oldProfil = self.fetch(profil.userid) {
            
            oldProfil.userid = profil.userid
            oldProfil.access_token = profil.access_token
            oldProfil.refresh_token = profil.refresh_token
            oldProfil.expire_in = profil.expire_in
            oldProfil.name = profil.name
            oldProfil.gender = profil.gender
            oldProfil.temp_unit = profil.temp_unit
            
            var error: NSError?
            managedObjectContext.save(&error)
            
            if let err = error {
                NSLog(err.localizedFailureReason!);
            } else {
                NSLog("Contact updated");
            }
        } else {
        
        }
    }
}