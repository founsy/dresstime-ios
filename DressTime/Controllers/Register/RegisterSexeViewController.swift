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
        self.navigationController?.navigationBarHidden = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "selectStyle"){
            if let viewController = segue.destinationViewController as? RegisterStyleViewController {
                viewController.user = self.user
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
            let cell = self.tableView.dequeueReusableCellWithIdentifier("sexeCell") as! RegisterSexeTableViewCell
            cell.titleLabel.text = NSLocalizedString("registerSexeWomen", comment: "").uppercaseString
            cell.imageViewBackground.image = UIImage(named: "RegisterBgWomen")
            return cell
        } else if (indexPath.row == 1){
            let cell = self.tableView.dequeueReusableCellWithIdentifier("sexeCell") as! RegisterSexeTableViewCell
            cell.titleLabel.text = NSLocalizedString("registerSexeMen", comment: "").uppercaseString
            cell.imageViewBackground.image = UIImage(named: "RegisterBgMen")
            return cell
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