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
        self.managedObjectContext = appDelegate.managedObjectContext
    }
    
    
    
    func fetch(userId: String) -> Profil? {
        let fetchRequest = NSFetchRequest(entityName: "Profil")
        let predicate = NSPredicate(format: "userid = %@", userId)
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        do {
            if let list = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Profil] {
                if (list.count > 0){
                    return list[0]
                } else {
                    return nil
                }
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func fetchLastUserConnected() -> Profil?{
        let fetchRequest = NSFetchRequest(entityName: "Profil")
        let predicate = NSPredicate(format: "access_token != \"\"")
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        do {
            if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Profil] {
                if (fetchResults.count > 0){
                    return fetchResults[0]
                } else {
                    return nil
                }
            }
        } catch let error as NSError {
                // failure
                print("Fetch failed: \(error.localizedDescription)")
        }
            
        return nil

    }
    
    func fetch() -> [Profil]? {
        let fetchRequest = NSFetchRequest(entityName: "Profil")
        do {
            if let fetchResults = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Profil] {
                if (fetchResults.count > 0){
                    return fetchResults
                } else {
                    return nil
                }
            }
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
        }
        return nil
    }
    
    func save(userid: String, access_token: String, refresh_token: String, expire_in: Int, name: String, gender: String, temp_unit: String) -> Profil{
        let entityDescription = NSEntityDescription.entityForName("Profil", inManagedObjectContext: managedObjectContext);
        let profil = Profil(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        profil.userid = userid
        profil.access_token = access_token
        profil.refresh_token = refresh_token
        profil.expire_in = expire_in
        profil.name = name
        profil.gender = gender
        profil.temp_unit = temp_unit
        
        do {
            try managedObjectContext.save()
             NSLog("Contact Saved");
        } catch let error as NSError {
             NSLog(error.localizedFailureReason!);
        }
        
        return profil
    }
    
    func update(profil: Profil) -> Profil? {
        if let oldProfil = self.fetch(profil.userid) {
            
            oldProfil.userid = profil.userid
            oldProfil.access_token = profil.access_token
            oldProfil.refresh_token = profil.refresh_token
            oldProfil.expire_in = profil.expire_in
            oldProfil.name = profil.name
            oldProfil.gender = profil.gender
            oldProfil.temp_unit = profil.temp_unit
            
            do {
                try managedObjectContext.save()
                return oldProfil
            } catch let error as NSError {
                print(error)
                return nil
            }

        } else {
            return nil
        }
    }
}