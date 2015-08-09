//
//  ViewController.swift
//  Today
//
//  Created by yof on 08/08/2015.
//  Copyright (c) 2015 dresstime. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController  {
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Cannot find how to make the background invisible !!!!
        self.navigationController?.navigationBar.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func exitView (sender: UIStoryboardSegue) {
        // Use to exit a view
    }
    

}


