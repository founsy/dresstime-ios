//
//  ViewController.swift
//  login
//
//  Created by Fabian Langlet on 7/19/16.
//  Copyright © 2016 Fabian Langlet. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    @IBAction func onSignInTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("signinShow", sender: self)
    }
    
    @IBAction func onSignUpTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("createAccountShow", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        setLocalization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setLocalization(){
        signInButton.setTitle(NSLocalizedString("registerSignInButton", comment: "Sign In"), forState: .Normal)
        createAccountButton.setTitle(NSLocalizedString("registerCreateAccountButton", comment: "Create an account"), forState: .Normal)
    }
}

