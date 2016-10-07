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
    
    
    @IBAction func onSignInTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "signinShow", sender: self)
    }
    
    @IBAction func onSignUpTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "createAccountShow", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setLocalization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setLocalization(){
        signInButton.setTitle(NSLocalizedString("registerSignInButton", comment: "Sign In"), for: UIControlState())
        createAccountButton.setTitle(NSLocalizedString("registerCreateAccountButton", comment: "Create an account"), for: UIControlState())
    }
}

