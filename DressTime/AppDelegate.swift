    //
//  AppDelegate.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.  
//

import UIKit
import CoreData
import CoreLocation
import Mixpanel
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import Appsee

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentUser:Profil?
    var errorManager = ErrorsManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("didFinishLaunchingWithOptions")
       
        Fabric.with([Crashlytics.self])
        Fabric.with([Appsee.self])
        
        _ = Mixpanel.sharedInstance(withToken: "fbe8acba2c1532169cd509ab5838e1ed")
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:  [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.identify(mixpanel.distinctId)
        
        //Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //OneSignal Push Notification
        _ = OneSignal(launchOptions: launchOptions, appId: "b0963a36-5d81-44c5-89bb-06f55c3fec1e") { (message, additionalData, isActive) in
            print("OneSignal Notification opened:\nMessage:\(message)")
            
            if additionalData != nil {
                print("additionalData: \(additionalData)")
                // Check for and read any custom values you added to the notification
                // This done with the "Additonal Data" section the dashbaord.
                // OR setting the 'data' field on our REST API.
                if let customKey = additionalData?["customKey"] as! String? {
                    print("customKey: \(customKey)")
                }
            }
        }
        
        let profilDAL = ProfilsDAL()
            _ = profilDAL.fetchLastUserConnected()
            
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "userId") {
            if let profil = profilDAL.fetch(name) {
                SharedData.sharedInstance.currentUserId = profil.userid
                SharedData.sharedInstance.sexe = profil.gender
                LoginBL().updateStyle(profil)
                
                mixpanel.people.set(["sexe" : profil.gender!, "$name" : profil.name!, "$email" : profil.email!, "Styles" : profil.styles!])
                
                Appsee.setUserID(profil.userid)

                DressingSynchro(userId: profil.userid!).migrateImageCoreDataToFile()
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavHomeViewController")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        
        //Remove all badges
        application.applicationIconBadgeNumber = 0
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSLog("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("applicationDidBecomeActive")
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
           NSLog("didRegisterForRemoteNotificationsWithDeviceToken")
        let mixPanel = Mixpanel.sharedInstance()
        mixPanel.people.addPushDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NSLog("didReceiveRemoteNotification")
    }
    
    fileprivate func openLaunchingScreen(){
        //Id
        
        if let _ = SharedData.sharedInstance.currentUserId {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
    }
    
    fileprivate func openMainNavScreen(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "NavHomeViewController") as? DTTabBarController
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.dresstime.test" in the application's documents Application Support directory.
        let urls = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DressTime", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("DressTime.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()

    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

