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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.CreateAccount, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.CreateAccount_Email_Duplicate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.CreateAccount_Style_Required, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.GetDressing, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.GetOutfit, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.Login, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.NoServer, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.SaveClothe, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.UploadClothe, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.displayErrorServer), name: Notifications.Error.SaveOutfit, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ErrorsManager.showLoginPage(_:)), name: Notifications.Error.NoAuthentication, object: nil)

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
        case Notifications.Error.CreateAccount_Email_Duplicate:
            title = NSLocalizedString("registerErrorCreateAccounEmailDuplicatetTitle", comment: "")
            message = NSLocalizedString("registerErrorCreateAccountEmailDuplicateMessage", comment: "")
            actionTitle = NSLocalizedString("registerErrorCreateAccountEmailDuplicateButton", comment: "")
            break
        case Notifications.Error.CreateAccount_Style_Required:
            title = NSLocalizedString("registerErrorCreateAccountStyleReguiredTitle", comment: "")
            message = NSLocalizedString("registerErrorCreateAccountStyleReguiredMessage", comment: "")
            actionTitle = NSLocalizedString("registerErrorCreateAccountStyleReguiredButton", comment: "")
            break
        case Notifications.Error.GetDressing:
            title = NSLocalizedString("getDressingErrTitle", comment: "")
            message = NSLocalizedString("getDressingErrMessage", comment: "")
            actionTitle = NSLocalizedString("getDressingErrButton", comment: "")
            break
        case Notifications.Error.GetOutfit:
            title = NSLocalizedString("getOutfitErrTitle", comment: "")
            message = NSLocalizedString("getOutfitErrMessage", comment: "")
            actionTitle = NSLocalizedString("getOutfitErrButton", comment: "")
            break
        case Notifications.Error.Login:
            title = NSLocalizedString("loginErrTitle", comment: "")
            message = NSLocalizedString("loginErrMessage", comment: "")
            actionTitle = NSLocalizedString("loginErrButton", comment: "")
            break
        case Notifications.Error.NoServer:
            title = NSLocalizedString("homeLocErrTitle", comment: "")
            message = NSLocalizedString("homeErrorNoAccessInternet", comment: "")
            actionTitle = NSLocalizedString("homeLocErrButton", comment: "")
            break
        case Notifications.Error.SaveClothe:
            title = NSLocalizedString("saveClotheErrTitle", comment: "")
            message = NSLocalizedString("saveClotheErrMessage", comment: "")
            actionTitle = NSLocalizedString("saveClotheErrButton", comment: "")
            break
        case Notifications.Error.UploadClothe:
            title = NSLocalizedString("uploadClotheErrTitle", comment: "")
            message = NSLocalizedString("uploadClotheErrMessage", comment: "")
            actionTitle = NSLocalizedString("uploadClotheErrButton", comment: "")
            break
        case Notifications.Error.SaveOutfit:
            title = NSLocalizedString("saveOutfitErrTitle", comment: "")
            message = NSLocalizedString("saveOutfitErrMessage", comment: "")
            actionTitle = NSLocalizedString("saveOutfitErrButton", comment: "")
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
    
    func showLoginPage(error: NSNotification){
        let loginBL = LoginBL()
        loginBL.logoutWithSuccess(nil)
        loginBL.showLoginPage(error)
    }
}

public struct Notifications {
    public struct Error {
        public static let NoServer = "errorServer"
        public static let SaveClothe = "saveClothe"
        public static let UploadClothe = "uploadClothe"
        public static let GetDressing = "getDressing"
        public static let GetOutfit = "getOutfit"
        public static let SaveOutfit = "saveOutfit"
        public static let CreateAccount = "createAccount"
        public static let Login = "login"
        public static let UpdateClothe = "updateClothe"
        public static let CreateAccount_Email_Duplicate = "createAccount_Email_Duplicate"
        public static let CreateAccount_Style_Required = "createAccount_Style_Required"
        public static let NoAuthentication = "error_noauthentication"
    }
}
