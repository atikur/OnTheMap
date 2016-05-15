//
//  StudentListViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

class StudentListViewController: UITableViewController {
    
    // MARK: - Properties
    
    let otmClient = OTMClient.sharedInstance()
    let otmModel = OTMModel.sharedInstance()
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        OTMClient.logoutFromViewController(self)
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentListViewController.studentInfoReceived), name: DidReceiveStudentInfoNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func studentInfoReceived() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }

    // MARK: -
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otmModel.studentList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentInfo = otmModel.studentList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
        cell.textLabel?.text = studentInfo.firstName + " " + studentInfo.lastName
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = otmModel.studentList[indexPath.row]
        
        if let url = NSURL(string: studentInfo.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
