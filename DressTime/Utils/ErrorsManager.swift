//
//  ErrorsManager.swift
//  DressTime
//
//  Created by Fab on 6/9/16.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation
import UIKit

class ErrorsManager: NSObject {
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.NoServer, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.SaveClothe, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.GetDressing, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.GetOutfit, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func displayErrorServer(error: NSNotification){
        var title = "", message = "", actionTitle = ""
        
        switch(error.name){
        case Notifications.Error.CreateAccount:
            title = NSLocalizedString("registerErrorCreateAccountTitle", comment: "")
            message = NSLocalizedString("registerErrorCreateAccountMessge", comment: "")
            actionTitle = NSLocalizedString("registerErrorCreateAccountButton", comment: "")
            break
        case Notifications.Error.GetDressing:
            break
        case Notifications.Error.GetOutfit:
            title = NSLocalizedString("homeLocErrTitle", comment: "")
            message = NSLocalizedString("homeErrorNoAccessInternet", comment: "")
            actionTitle = NSLocalizedString("homeLocErrButton", comment: "")
            break
        case Notifications.Error.Login:
            break
        case Notifications.Error.NoServer:
            break
        case Notifications.Error.SaveClothe:
            break
        case Notifications.Error.SaveOutfit:
            break
        default:
            title = ""
            message = ""
            actionTitle = ""
            break
        }
        
        if let appDelegate = UIApplication.sharedApplication().delegate, let window = appDelegate.window {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .Default) { _ in })
            dispatch_async(dispatch_get_main_queue(), {
                window!.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
}

public struct Notifications {
    public struct Error {
        public static let NoServer = "errorServer"
        public static let SaveClothe = "saveClothe"
        public static let GetDressing = "getDressing"
        public static let GetOutfit = "getOutfit"
        public static let SaveOutfit = "saveOutfit"
        public static let CreateAccount = "createAccount"
        public static let Login = "login"
    }
}
