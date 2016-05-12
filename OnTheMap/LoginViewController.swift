//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/11/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        guard let email = emailTextField.text, password = passwordTextField.text where !email.isEmpty && !password.isEmpty else {
            infoLabel.text = "Email/password field empty."
            return
        }
        
        loginWithEmail(email, password: password)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = ""
    }
    
    func loginWithEmail(email: String, password: String) {
        let url = NSURL(string: "https://www.udacity.com/api/session")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            let parsedResult: AnyObject
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Can't parse json")
                return
            }
            
            guard let sessionDict = parsedResult["session"] as? [String: AnyObject], sessionID = sessionDict["id"] else {
                print("can't get session id")
                dispatch_async(dispatch_get_main_queue()) {
                    self.infoLabel.text = "Wrong email/password."
                }
                return
            }
            
            print("session id: \(sessionID)")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.infoLabel.text = "Successfully logged in."
            }
        }
        
        task.resume()
    }
}

