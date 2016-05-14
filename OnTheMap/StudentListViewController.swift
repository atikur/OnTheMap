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
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logout()
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
    
    func logout() {
        let request = OTMClient.requestForUdacityLogout()
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let result = result,
                sessionDict = result["session"] as? [String: AnyObject],
                sessionID = sessionDict["id"] as? String else {
                    return
            }
            
            self.otmClient.udacitySessionID = nil
            self.otmClient.udacityUserID = nil
            self.otmClient.studentList = []
            
            print("logged out successfully: \(sessionID)")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func getStudentInfo() {
        let request = OTMClient.requestForStudentInfoRetrieval()
        
        otmClient.taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.displayError("Error", message: "Can't get student information.")
                return
            }
            
            guard let result = result, studentInfoResults = result["results"] as? [[String: AnyObject]] else {
                self.displayError("Error", message: "Can't get student information.")
                return
            }
            
            self.otmClient.studentList = StudentInformation.studentInformationFromResults(studentInfoResults)
            NSNotificationCenter.defaultCenter().postNotificationName(DidReceiveStudentInfoNotification, object: nil)
        }
    }
    
    func displayError(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            OTMClient.showAlert(self, title: title, message: message)
        }
    }

    // MARK: -
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = otmClient.studentList[indexPath.row]
        
        if let url = NSURL(string: studentInfo.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
