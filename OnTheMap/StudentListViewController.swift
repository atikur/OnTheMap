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
    var studentLocations = [OTMStudentLocation]()
    
    override func viewDidLoad() {
        let url = NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=50")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        otmClient.taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let result = result, studentLocationResults = result["results"] as? [[String: AnyObject]] else {
                return
            }
            
            self.studentLocations = OTMStudentLocation.studentLocationFromResults(studentLocationResults)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell")!
        cell.textLabel?.text = studentLocations[indexPath.row].firstName + " " + studentLocations[indexPath.row].lastName
        cell.imageView?.image = UIImage(named: "pin")
        return cell
    }
    
}
