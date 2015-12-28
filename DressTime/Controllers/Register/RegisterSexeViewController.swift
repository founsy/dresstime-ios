//
//  RegisterSexeViewController.swift
//  DressTime
//
//  Created by Fab on 22/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class RegisterSexeViewController: DTViewController {
    var email: String?
    var password: String?
    private var sexe: String?
    
    var user: User?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onCancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterSexe"
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectStyle"){
            if let viewController = segue.destinationViewController as? RegisterStyleViewController {
                viewController.email = self.email
                viewController.password = self.password
                viewController.sexe = self.sexe
            }
        }
    }
}

extension RegisterSexeViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        NSLog("\(indexPath.row)")
        if (indexPath.row == 0){
            return self.tableView.dequeueReusableCellWithIdentifier("womenCell")!
        } else if (indexPath.row == 1){
            return self.tableView.dequeueReusableCellWithIdentifier("menCell")!
        }
        return UITableViewCell()
    }
}

extension RegisterSexeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.tableView.frame.height/2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0){
            self.user?.gender = "F"
            sexe = "F"
        } else if (indexPath.row == 1){
            sexe = "M"
            self.user?.gender = "M"
        }
        self.performSegueWithIdentifier("selectStyle", sender: self)
    }
    
}