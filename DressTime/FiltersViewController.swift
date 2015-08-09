//
//  TodayViewController.swift
//  Today
//
//  Created by yof on 09/08/2015.
//  Copyright (c) 2015 dresstime. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    
    private var styles = [ "WORK - Business style", "BE CHIC - Casual style", "RELAX - Sportswear style", "PARTY - Fashion style" ]
    
    private var currentStyle: String = "all"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func exitView (sender: UIStoryboardSegue) {
        // Use to exit a view
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension FiltersViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.styles.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.styles[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?{
        let titleData = self.styles[row]
        var myTitle = NSAttributedString(
            string: titleData,
            attributes: [
                NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
        )
        
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.currentStyle = self.styles[row]
    }
    
}

