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

        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.CreateAccount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.CreateAccount_Email_Duplicate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.CreateAccount_Style_Required, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.GetDressing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.GetOutfit, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.Login, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.NoServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.SaveClothe, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.UploadClothe, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.displayErrorServer(_:)), name: Notifications.Error.SaveOutfit, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ErrorsManager.showLoginPage(_:)), name: Notifications.Error.NoAuthentication, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func displayErrorServer(_ error: Foundation.Notification){
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
        case Notifications.Error.NoAuthentication:
            showLoginPage(error)
        default:
            title = ""
            message = ""
            actionTitle = ""
            break
        }
        
        if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in })
            DispatchQueue.main.async(execute: {
                window!.rootViewController?.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    func showLoginPage(_ error: Foundation.Notification){
        let loginBL = LoginBL()
        loginBL.logoutWithSuccess(nil)
        loginBL.showLoginPage(error)
    }
}

public struct Notifications {
    public struct Error {
        public static let NoServer = Notification.Name("errorServer")
        public static let SaveClothe = Notification.Name("saveClothe")
        public static let UploadClothe = Notification.Name("uploadClothe")
        public static let GetDressing = Notification.Name("getDressing")
        public static let GetOutfit = Notification.Name("getOutfit")
        public static let SaveOutfit = Notification.Name("saveOutfit")
        public static let CreateAccount = Notification.Name("createAccount")
        public static let Login = Notification.Name("login")
        public static let UpdateClothe = Notification.Name("updateClothe")
        public static let CreateAccount_Email_Duplicate = Notification.Name("createAccount_Email_Duplicate")
        public static let CreateAccount_Style_Required = Notification.Name("createAccount_Style_Required")
        public static let NoAuthentication = Notification.Name("error_noauthentication")
    }
}
