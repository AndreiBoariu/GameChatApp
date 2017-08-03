//
//  PopoverWithTableViewVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

protocol PopoverWithTableViewVCDelegate: class {
    func popoverWithTableViewVC_userDidSelectObject(_ obj : String )
}

class PopoverWithTableViewVC: UIViewController {
    
    @IBOutlet weak var tblData : UITableView!
    
    weak var delegate:PopoverWithTableViewVCDelegate?
    
    var arrData =  [String]()
    var strTitle = String()

    //MARK: - View Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblData.separatorInset = UIEdgeInsets.zero
        UITableView.appearance().layoutMargins = UIEdgeInsets.zero
        UITableViewCell.appearance().layoutMargins = UIEdgeInsets.zero
        UITableViewCell.appearance().preservesSuperviewLayoutMargins = false

        //=>    Hide extra separtors
        tblData.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidLayoutSubviews() {
        //topView.backgroundColor = appDelegate.getGlobalColor()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellPopover", for: indexPath) 
        
        // Configure the cell...
        
        let strMenuOption = arrData[indexPath.row]
        cell.textLabel?.text = strMenuOption
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.openSans_SemiBold_OfSize(15.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        //=>    Deselect cell
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedObject = arrData[indexPath.row]
        
        //=>    Send data in delegate method
        delegate?.popoverWithTableViewVC_userDidSelectObject(selectedObject)
    }

    //MARK: Memory Warning
    override func didReceiveMemoryWarning()
    {
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
