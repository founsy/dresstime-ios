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
            let list = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Profil]
            
            if (list != nil && list!.count > 0){
                return list![0]
            } else {
                return nil
            }
        } catch let fetchError as NSError {
            print("getGalleryForItem error: \(fetchError.localizedDescription)")
            return nil
        }
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
    
    /*func save(userid: String, email: String, firstName: String, lastName: String, access_token: String, refresh_token: String, expire_in: Int, name: String, gender: String, temp_unit: String) -> Profil{
        
        let entityDescription = NSEntityDescription.entityForName("Profil", inManagedObjectContext: managedObjectContext);
        let profil = Profil(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        profil.userid = userid
        profil.access_token = access_token
        profil.refresh_token = refresh_token
        profil.expire_in = expire_in
        profil.name = name
        profil.gender = gender
        profil.temp_unit = temp_unit
        profil.email = email
        profil.firstName = firstName
        profil.lastName = lastName
        
        do {
            try managedObjectContext.save()
             NSLog("Contact Saved");
        } catch let error as NSError {
             NSLog(error.localizedFailureReason!);
        }
        
        return profil
    } */
    
    func save(user: User) -> Profil? {
        let entityDescription = NSEntityDescription.entityForName("Profil", inManagedObjectContext: managedObjectContext);
        let profil = Profil(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext);
        
        profil.userid = user.email
        profil.access_token = user.access_token
        profil.refresh_token = user.refresh_token
        profil.expire_in = user.expire_in
        profil.name = user.displayName
        profil.gender = user.gender
        profil.temp_unit = user.tempUnit
        profil.email = user.email
        profil.fb_id = user.fb_id
        profil.fb_token = user.fb_token
        profil.picture_url = user.picture
        profil.picture = user.picture_data
        profil.firstName = user.firstName
        profil.lastName = user.lastName
        profil.styles = user.styles
        profil.notification = user.notification
        
        do {
            try managedObjectContext.save()
            NSLog("Contact Saved");
            SharedData.sharedInstance.currentUserId = profil.userid
            SharedData.sharedInstance.sexe = profil.gender
            
            return profil
        } catch let error as NSError {
            NSLog(error.localizedFailureReason!);
            return nil
        }
    }
    
    func update(profil: Profil) -> Profil? {
        if let oldProfil = self.fetch(profil.userid!) {
            
            oldProfil.userid = profil.userid
            oldProfil.access_token = profil.access_token
            oldProfil.refresh_token = profil.refresh_token
            oldProfil.expire_in = profil.expire_in
            oldProfil.name = profil.name
            oldProfil.gender = profil.gender
            oldProfil.temp_unit = profil.temp_unit
            oldProfil.email = profil.email
            oldProfil.styles = profil.styles
            oldProfil.firstName = profil.firstName
            oldProfil.lastName = profil.lastName
            oldProfil.styles = profil.styles
            oldProfil.notification = profil.notification
            oldProfil.picture = profil.picture
            
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
    
    func update(user: User) -> Profil? {
        if let oldProfil = self.fetch(SharedData.sharedInstance.currentUserId!) {
            
            oldProfil.access_token = user.access_token
            oldProfil.refresh_token = user.refresh_token
            oldProfil.expire_in = user.expire_in
            oldProfil.name = user.displayName
            oldProfil.gender = user.gender
            oldProfil.temp_unit = user.tempUnit
            oldProfil.email = user.email
            oldProfil.styles = user.styles
            oldProfil.firstName = user.firstName
            oldProfil.lastName = user.lastName
            oldProfil.styles = user.styles
            oldProfil.notification = user.notification
            
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
    
    private func getStyles(profil: Profil) -> String?{
        var styles = [String]()
        if let _ = profil.atWorkStyle {
            styles.append(profil.atWorkStyle!)
            if (!styles.contains(profil.onPartyStyle!)){
                styles.append(profil.onPartyStyle!)
            }
            if (!styles.contains(profil.relaxStyle!)){
                styles.append(profil.relaxStyle!)
            }
            
            return styles.joinWithSeparator(",")
        }
        return nil
    }
}