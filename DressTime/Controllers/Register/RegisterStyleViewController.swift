//
//  RegisterStyleViewControllerNew.swift
//  DressTime
//
//  Created by Fab on 17/02/2016.
//  Copyright © 2016 Fab. All rights reserved.
//

import Foundation

class RegisterStyleViewController: DTViewController {
    
    @IBOutlet weak var panel: UIVisualEffectView!
    
    @IBOutlet weak var heightPanelCst: NSLayoutConstraint!
    @IBOutlet var imageHeight: [NSLayoutConstraint]!
    @IBOutlet var imageWidth: [NSLayoutConstraint]!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var workArea: UIImageView!
    @IBOutlet weak var partyArea: UIImageView!
    @IBOutlet weak var relaxArea: UIImageView!
    @IBOutlet var buttonsStyle: [UIButton]!
    
    @IBOutlet weak var validationButton: UIButton!
    
    @IBOutlet weak var selectStyleLabel: UILabel!
    @IBOutlet weak var fashionStyleLabel: UILabel!
    @IBOutlet weak var businessStyleLabel: UILabel!
    @IBOutlet weak var sportwearStyleLabel: UILabel!
    @IBOutlet weak var casualStyleLabel: UILabel!
    @IBOutlet weak var selectPeriodLabel: UILabel!
    @IBOutlet weak var workPeriodLabel: UILabel!
    @IBOutlet weak var partyPeriodLabel: UILabel!
    @IBOutlet weak var chillPeriodLabel: UILabel!
    
    
    private var isOpen = false
    private var isStyleSelected = false
    private var currentStyleSelected: String?
    private let workRec = UITapGestureRecognizer()
    private let partyRec = UITapGestureRecognizer()
    private let relaxRec = UITapGestureRecognizer()
    
    private var relaxSelected: String?
    private var atWorkSelected: String?
    private var onPartySelected: String?
    
    private var confirmationView: ConfirmSave?
    
    var currentUserId: String?
    
    var email: String?
    var password: String?
    var sexe: String?
    var user: User?
    
    
    @IBAction func buttonsStyle(sender: AnyObject) {
        for (var i = 0; i < buttonsStyle.count; i++){
            if (buttonsStyle[i] == sender as! UIButton){
                buttonsStyle[i].selected = !buttonsStyle[i].selected
                isStyleSelected = buttonsStyle[i].selected
                if (isStyleSelected){
                    currentStyleSelected = buttonsStyle[i].accessibilityIdentifier
                    openPanel()
                } else {
                    currentStyleSelected = nil
                    closePanel()
                }
            } else {
                buttonsStyle[i].selected = false
            }
        }
    }
    
    @IBAction func onSaveTapped(sender: AnyObject) {
        //Edit Mode
        if (!isValidData()){
            ActivityLoader.shared.hideProgressView()
            let alert = UIAlertController(title: NSLocalizedString("registerStyleErrTitle", comment: ""), message: NSLocalizedString("registerStyleErrMessage", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("registerStyleErrButton", comment: ""), style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            return
        }
        
        //Update Current User
        if let userId = currentUserId {
            let dal = ProfilsDAL()
            if let profil = dal.fetch(userId) {
                profil.atWorkStyle = self.atWorkSelected
                profil.onPartyStyle = self.onPartySelected
                profil.relaxStyle = self.relaxSelected
                
                let newProfil = dal.update(profil)
                UserService().UpdateUser(newProfil!, completion: { (isSuccess, object) -> Void in
                    self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                    self.view.bringSubviewToFront(self.confirmationView!)
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.confirmationView?.alpha = 1
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                        }, completion: { (isFinish) -> Void in
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.confirmationView?.alpha = 0
                                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                                }, completion: { (finish) -> Void in
                                     self.navigationController?.popViewControllerAnimated(true)
                            })
                    })
                })
                
                
            }
        } else { //Create new User
            let dal = ProfilsDAL()
            self.user?.atWorkStyle = self.atWorkSelected
            self.user?.onPartyStyle = self.onPartySelected;
            self.user?.relaxStyle = self.relaxSelected
            let profil = dal.save(self.user!)
            
            UserService().CreateUser(profil, password: self.user!.password, completion: { (isSuccess, object) -> Void in
                if (isSuccess){
                    //Create Model
                    if (FBSDKAccessToken.currentAccessToken() == nil){
                        self.loginSuccess(profil, password: self.user!.password!)
                    } else {
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(profil.userid, forKey: "userId")
                        defaults.synchronize()
                    }
                    SharedData.sharedInstance.currentUserId = profil.userid
                    SharedData.sharedInstance.sexe = profil.gender
                    
                    UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                        self.confirmationView?.alpha = 1
                        self.confirmationView?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                        }, completion: { (isFinish) -> Void in
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.confirmationView?.alpha = 0
                                self.confirmationView?.layer.transform = CATransform3DMakeScale(0.5 , 0.5, 1.0)
                                }, completion: { (finish) -> Void in
                                    dispatch_async(dispatch_get_main_queue(),  { () -> Void in
                                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("NavHomeViewController")
                                        appDelegate.window?.rootViewController = initialViewController
                                        appDelegate.window?.makeKeyAndVisible()
                                    })
                            })
                    })
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("registerErrorCreateAccountTitle", comment: ""), message: NSLocalizedString("registerErrorCreateAccountMessge", comment: ""), preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("registerErrorCreateAccountButton", comment: ""), style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true){}
                
                }
            })
            
        }
    }
    
    override func viewDidLoad() {
        self.hideTabBar = true
        super.viewDidLoad()
        self.classNameAnalytics = "RegisterStyle"
        
        workRec.addTarget(self, action: "tappedMoment:")
        workArea.userInteractionEnabled = true
        workArea.addGestureRecognizer(workRec)
        
        partyRec.addTarget(self, action: "tappedMoment:")
        partyArea.userInteractionEnabled = true
        partyArea.addGestureRecognizer(partyRec)
        
        relaxRec.addTarget(self, action: "tappedMoment:")
        relaxArea.userInteractionEnabled = true
        relaxArea.addGestureRecognizer(relaxRec)
        
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        panel.addGestureRecognizer(upSwipe)
        panel.addGestureRecognizer(downSwipe)
        
        self.changeLabel() //Change Button Label
        self.createConfirmationView()
        
        /* Set Translation */
        selectStyleLabel.text = NSLocalizedString("registerStyleSelectStyle", comment: "").uppercaseString
        fashionStyleLabel.text = NSLocalizedString("registerStyleFashionStyle", comment: "")
        businessStyleLabel.text = NSLocalizedString("registerStyleBusinessStyle", comment: "")
        sportwearStyleLabel.text = NSLocalizedString("registerStyleSportwearStyle", comment: "")
        casualStyleLabel.text = NSLocalizedString("registerStyleCasualStyle", comment: "")
        selectPeriodLabel.text = NSLocalizedString("registerStyleSelectPeriod", comment: "").uppercaseString
        workPeriodLabel.text = NSLocalizedString("registerStyleWorkPeriod", comment: "")
        partyPeriodLabel.text = NSLocalizedString("registerStylePartyPeriod", comment: "")
        chillPeriodLabel.text = NSLocalizedString("registerStyleChillPeriod", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = currentUserId {
            initData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSmallImage(){
        workArea.image = UIImage(named : "areaSmallW")
        partyArea.image = UIImage(named : "areaSmallP")
        relaxArea.image = UIImage(named : "areaSmallC")
    }
    
    func setBigImage(){
        workArea.image = UIImage(named : "areaBigW")
        partyArea.image = UIImage(named : "areaBigP")
        relaxArea.image = UIImage(named : "areaBigC")
    }
    
    
    func openPanel(){
        self.heightPanelCst.constant = 315
        self.bottomMargin.constant = 45
        for (var i = 0; i < self.imageHeight.count; i++){
            self.imageHeight[i].constant = 90
            self.imageWidth[i].constant = 90
        }
       
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.setBigImage()
            }) { (isFinish) -> Void in
                self.isOpen = true
        }
    }
    
    func closePanel(){
        self.heightPanelCst.constant = 120
        self.bottomMargin.constant = 22
        for (var i = 0; i < self.imageHeight.count; i++){
            self.imageHeight[i].constant = 40
            self.imageWidth[i].constant = 40
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.setSmallImage()
            }) { (isFinish) -> Void in
                self.isOpen = false
        }
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Up) {
            if (!self.isOpen){
                openPanel()
            }
        } else if (sender.direction == .Down) {
            if (self.isOpen){
                closePanel()
            }
        }
        
    }
    
    func tappedMoment(sender: UIGestureRecognizer){
        if let style = currentStyleSelected {
            let view = UIImageView(image: UIImage(named: getImageNamed(style)))
            view.frame = CGRectMake(0, 0, 70, 70)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if (sender.view as! UIImageView == workArea){
                if (workArea.subviews.count > 0){
                    removeSubviews(workArea)
                }
                workArea.addSubview(view)
                createConstraint(view, targetArea: workArea)
                atWorkSelected = style
            } else if (sender.view as! UIImageView == partyArea){
                if (partyArea.subviews.count > 0){
                    removeSubviews(partyArea)
                }
                partyArea.addSubview(view)
                createConstraint(view, targetArea: partyArea)
                onPartySelected = style
            } else if (sender.view as! UIImageView == relaxArea){
                if (relaxArea.subviews.count > 0){
                    removeSubviews(relaxArea)
                }
                relaxArea.addSubview(view)
                createConstraint(view, targetArea: relaxArea)
                relaxSelected = style
            }
            unSelectedStyle()
            closePanel()
        }
    }
    
    private func unSelectedStyle(){
        for (var i = 0; i < buttonsStyle.count; i++){
            if (buttonsStyle[i].accessibilityIdentifier == currentStyleSelected){
                buttonsStyle[i].selected = false
            }
        }
    }
    
    private func removeSubviews(containerView: UIView){
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
    }
    
    private func initData(){
        let profilDal = ProfilsDAL()
        if let user = profilDal.fetch(self.currentUserId!) {
            if let style = user.onPartyStyle {
                //Add view to partyArea
                let view = UIImageView(image: UIImage(named: getImageNamed(style)))
                view.frame = CGRectMake(0, 0, 70, 70)
                view.translatesAutoresizingMaskIntoConstraints = false
               /* let button = UIButton(frame: CGRectMake(0, 0, 10, 10))
                button.setTitle("X", forState: .Normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(button) */
                partyArea.addSubview(view)
                onPartySelected = style
                createConstraint(view, targetArea: partyArea)
                //createConstraintButton(view, button: button)
            }
            if let style = user.relaxStyle {
                //Add view to partyArea
                let view = UIImageView(image: UIImage(named: getImageNamed(style)))
                view.frame = CGRectMake(0, 0, 70, 70)
                view.translatesAutoresizingMaskIntoConstraints = false
                relaxArea.addSubview(view)
                relaxSelected = style
                createConstraint(view, targetArea: relaxArea)
            }
            if let style = user.atWorkStyle{
                //Add view to partyArea
                let view = UIImageView(image: UIImage(named: getImageNamed(style)))
                view.frame = CGRectMake(0, 0, 70, 70)
                view.translatesAutoresizingMaskIntoConstraints = false
                workArea.addSubview(view)
                atWorkSelected = style
                createConstraint(view, targetArea: workArea)
            }
        }
    }
    
    private func isValidData() -> Bool {
        return !((relaxSelected == nil || relaxSelected!.isEmpty) ||
            (onPartySelected == nil || onPartySelected!.isEmpty) ||
            (atWorkSelected == nil || atWorkSelected!.isEmpty))
    }
    
    private func changeLabel(){
        if (currentUserId != nil){
            validationButton.setTitle(NSLocalizedString("registerStyleValidateModificationBtn", comment: ""), forState: UIControlState.Normal)
        } else {
            validationButton.setTitle(NSLocalizedString("registerStyleSeeMyNewDressingBtn", comment: ""), forState: UIControlState.Normal)
        }
    }
    
    private func createConfirmationView(){
        self.confirmationView = NSBundle.mainBundle().loadNibNamed("ConfirmSave", owner: self, options: nil)[0] as? ConfirmSave
        self.confirmationView!.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2.0 - 50, UIScreen.mainScreen().bounds.size.height/2.0 - 50, 100, 100)
        self.confirmationView!.alpha = 0
        self.confirmationView!.layer.cornerRadius = 50
    
        self.view.addSubview(self.confirmationView!)
    }
    
    private func createConstraint(imageView: UIImageView, targetArea: UIImageView){
        let leadingConstraint = imageView.leadingAnchor.constraintEqualToAnchor(targetArea.leadingAnchor, constant: 5)
        let trailingConstraint = imageView.trailingAnchor.constraintEqualToAnchor(targetArea.trailingAnchor, constant: -5)
        let topConstraint = imageView.topAnchor.constraintEqualToAnchor(targetArea.topAnchor, constant: 5)
        let bottomConstraint = imageView.bottomAnchor.constraintEqualToAnchor(targetArea.bottomAnchor, constant: -5)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint,bottomConstraint])
    }
    
    private func createConstraintButton(imageView: UIImageView, button: UIButton){
        let topConstraint = button.topAnchor.constraintEqualToAnchor(imageView.topAnchor, constant: -5)
        let trailingConstraint = button.trailingAnchor.constraintEqualToAnchor(imageView.trailingAnchor, constant: -5)
        let widthConstraint = button.widthAnchor.constraintEqualToConstant(10.0)
        let heightConstraint = button.heightAnchor.constraintEqualToConstant(10.0)
        NSLayoutConstraint.activateConstraints([trailingConstraint, topConstraint, widthConstraint, heightConstraint])
    }
    
    private func getImageNamed(style: String) -> String {
        switch(style) {
        case "fashion":
            return "cocktailIcon_select"
        case "business":
            return "briefcaseIcon_select"
        case "sportwear":
            return "dumbbellIcon_select"
        case "casual":
            return "glassesIcon_select"
        default:
            return ""
        }
    }
    
    private func loginSuccess(profil: Profil, password: String){
        LoginService().Login(profil.email!, password: password) { (isSuccess, object) -> Void in
            if (isSuccess){
                let loginBL = LoginBL();
                loginBL.loginWithSuccess(object)
            } else {
                ActivityLoader.shared.hideProgressView()
                let alert = UIAlertController(title: NSLocalizedString("loginErrTitle", comment: ""), message: NSLocalizedString("loginErrMessage", comment: ""), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("loginErrButton", comment: ""), style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }
            
        }
        
    }

}
