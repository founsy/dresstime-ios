//
//  LoginViewController.swift
//  DressTime
//
//  Created by Fab on 17/07/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func onClickLoginBtn(sender: AnyObject) {
        let jsonObject: [String: AnyObject] = [
            "grant_type": "password",
            "client_id": "android",
            "client_secret": "SomeRandomCharsAndNumbers",
            "username": loginText.text,
            "password": passwordText.text,
        ];
        
        LoginService.loginMethod(jsonObject, postCompleted: { (succeeded: Bool, msg: [String: AnyObject]) -> () in
            if (succeeded){
                dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                    
                    var appDelegateTemp = UIApplication.sharedApplication().delegate;
                    appDelegateTemp!.window!!.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? UIViewController
                    
                    /*let todayController = TodayController()
                    let navController = NavigationController(rootViewController: todayController)
                    
                    self.presentViewController(navController, animated: true, completion: nil)*/
                })
                
            } else {
                var alert = UIAlertView(title: "Failed!", message: msg["error"] as? String, delegate: nil, cancelButtonTitle: "Okay.")
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.secureTextEntry = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
