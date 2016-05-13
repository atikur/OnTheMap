//
//  StudentListViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

class StudentListViewController: UITableViewController {
    
    let otmClient = OTMClient.sharedInstance()
    
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otmClient.studentList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentInfo = otmClient.studentList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
        cell.textLabel?.text = studentInfo.firstName + " " + studentInfo.lastName
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
