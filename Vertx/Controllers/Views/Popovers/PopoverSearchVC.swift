//
//  PopoverSearchVC.swift
//  Vertx
//
//  Created by Boariu Andy on 9/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import WYPopoverController

protocol PopoverSearchVCDelegate: class {
    func popoverSearchVC_searchActionWithSearchText(_ strSearchTextTemp: String?, andSearchTypes arrSearchTypesTemp: [String]?, andGamePlatform strGamePlatformTemp: String?)
    func popoverSearchVC_closePopover()
}

class PopoverSearchVC: UIViewController, WYPopoverControllerDelegate, PopoverWithTableViewVCDelegate {
    
    weak var delegate:PopoverSearchVCDelegate?
    
    @IBOutlet weak var txfSearch : UITextField!
    @IBOutlet weak var tblFeedTypes : UITableView!
    @IBOutlet weak var btnSearch : UIButton!
    @IBOutlet weak var btnPlatform : UIButton!
    
    var arrSelectedOptions = [String]()
    
    var customPopover = WYPopoverController()
    
    //=>    Vars for search
    var arrSearchTypesTemp: [String]?
    var strSearchTextTemp : String?
    var strSearchGamePlatformTemp: String?

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

        setupUI()
        
        //=>    Fill search info
        txfSearch.text = strSearchTextTemp
        btnPlatform.setTitle(strSearchGamePlatformTemp, for: UIControlState())
        if let arrTypes = arrSearchTypesTemp {
            for type in arrTypes {
                arrSelectedOptions.append(type)
            }
        }
        
        tblFeedTypes.reloadData()
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        
        btnSearch.layer.cornerRadius = 25.0
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        
//        customPopover.theme = WYPopoverTheme.themeForIOS7()
//        let popoverAppearance = WYPopoverBackgroundView.appearance()
//        popoverAppearance.fillTopColor = UIColor.vertxDarkOrange()
//        popoverAppearance.fillBottomColor = UIColor.vertxDarkOrange()
    }
    
    func displayPopoverWithTableView_MenuOptions(_ sender: UIButton, arrData: [String]) {
        
        //=>    Hide keyboard if is visible
        view.endEditing(true)
        
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
            
            return
        }
        
        if let popoverWithTableView       = self.storyboard?.instantiateViewController(withIdentifier: "PopoverWithTableViewVC") as? PopoverWithTableViewVC {
            popoverWithTableView.delegate = self
            popoverWithTableView.preferredContentSize = CGSize(width: 200, height: 146)
            popoverWithTableView.arrData  = arrData
            
            customPopover = WYPopoverController(contentViewController: popoverWithTableView)
            customPopover.delegate = self
            customPopover.passthroughViews = [sender]
            customPopover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
            customPopover.wantsDefaultContentAppearance = false
            customPopover.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection(rawValue: 2), animated: true)
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    @IBAction fileprivate func btnClosePopover_Action() {
        delegate?.popoverSearchVC_closePopover()
    }
    
    @IBAction fileprivate func btnSearch_Action() {
        var bShouldSearch = false
        
        if let strText = txfSearch.text, !strText.isEmpty {
            bShouldSearch = true
        }
        
        if let strPlatform = btnPlatform.titleLabel?.text, !strPlatform.isEmpty {
            bShouldSearch = true
        }
        
        if arrSelectedOptions.count > 0 {
            bShouldSearch = true
        }
        
        if bShouldSearch {
            delegate?.popoverSearchVC_searchActionWithSearchText(txfSearch.text, andSearchTypes: arrSelectedOptions, andGamePlatform: btnPlatform.titleLabel?.text)
        }
        else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Please select at least one option for search")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction fileprivate func btnGamePlatform_Action(_ sender: UIButton) {
        displayPopoverWithTableView_MenuOptions(sender, arrData: Constants.arrPlatforms)
    }
    
    // MARK: - UITableViewDelegate Methods
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.FeedKeys.arrFeedTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VXSearchFeedTypeCell_ID", for: indexPath) as! VXSearchFeedTypeCell
        
        let curType = Constants.FeedKeys.arrFeedTypes[indexPath.row]
        cell.lblFeedType.text = curType
        
        if arrSelectedOptions.contains(curType) {
            cell.imgSelected.image = UIImage(named: "checked")
        }
        else {
            cell.imgSelected.image = UIImage(named: "unchecked")
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let curType = Constants.FeedKeys.arrFeedTypes[indexPath.row]
        
        if arrSelectedOptions.contains(curType) {
            arrSelectedOptions.removeObject(curType)
        }
        else {
            arrSelectedOptions.append(curType)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - PopoverWithTableViewVCDelegate Methods
    func popoverWithTableViewVC_userDidSelectObject(_ obj: String) {
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
        }
        
        //=>    Feed Type option selected
        btnPlatform.setTitle(obj, for: UIControlState())
    }
    
    // MARK: - WYPopoverControllerDelegate Methods
    func popoverControllerShouldDismissPopover(_ popoverController: WYPopoverController!) -> Bool {
        return true
    }
    
    func popoverControllerDidDismissPopover(_ popoverController: WYPopoverController!) {
        if popoverController == customPopover {
            customPopover.delegate = nil
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
