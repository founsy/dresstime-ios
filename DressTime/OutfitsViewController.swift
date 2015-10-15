//
//  OutfitsViewController.swift
//  DressTime
//
//  Created by Fab on 09/09/2015.
//  Copyright (c) 2015 Fab. All rights reserved.
//

import Foundation
import UIKit

class OutfitsViewController : UIViewController {

    private var pageViewController: UIPageViewController?
    private var controllers = [OutfitViewController]()
    private var currentSection: Int = 0
    
    var styleOutfits: String?
    var outfitsCollection: JSON?
    var currentWeather: Weather?


    //@IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(
            transitionStyle: .PageCurl,
            navigationOrientation: .Horizontal,
            options: nil)
        
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
        
        loadOutfitsByStyle()
    }

    private func populateControllersArray() {
        if let outfits = self.outfitsCollection {
            for (key, subJson):(String, JSON) in outfits {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("OutfitViewController") as! OutfitViewController
                controller.currentOutfits = subJson["outfit"].arrayObject
                controller.itemIndex = Int(key)!
                self.view.layoutIfNeeded()
                controller.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
                
                controllers.append(controller)

            }
        }
    }

    private func setupPageControl() {
       /* if let outfits = self.outfitsCollection {
            self.pageControl.numberOfPages = outfits.count
        } */
    }

    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        
        //self.view.layoutIfNeeded()
        pageController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        if !controllers.isEmpty {
            pageController.setViewControllers([controllers[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func loadOutfitsByStyle(){
        DressTimeService().GetOutfitsByStyle(styleOutfits!, weather: self.currentWeather!) { (isSuccess, object) -> Void in
            if (isSuccess){
                self.outfitsCollection = object
                self.currentSection = 0
                self.populateControllersArray()
                self.createPageViewController()

            }
        }
        
       /* DressTimeService.getOutfitsByStyle(SharedData.sharedInstance.currentUserId!, style: styleOutfits!) { (succeeded, msg) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.outfitsCollection = msg
                self.currentSection = 0
                self.populateControllersArray()
                //self.setupPageControl()
                self.createPageViewController()
            })
        } */
    }

}

extension OutfitsViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? OutfitViewController {
            if controller.itemIndex > 0 {
                return controllers[controller.itemIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let controller = viewController as? OutfitViewController {
            if controller.itemIndex < controllers.count - 1 {
                return controllers[controller.itemIndex + 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //let itemController = pageViewController.viewControllers[0] as! OutfitViewController
        
        //self.pageControl.currentPage = itemController.itemIndex
    }
    
}