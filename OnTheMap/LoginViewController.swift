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
    
    let otmClient = OTMClient.sharedInstance()
    
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
    
    func updateInfoLabel(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.infoLabel.text = message
        }
    }
    
    func loginWithEmail(email: String, password: String) {
        let url = NSURL(string: "https://www.udacity.com/api/session")!
        let requestBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let request = OTMClient.postRequestWithURL(url, requestBody: requestBody)
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.updateInfoLabel("Wrong email/password.")
                return
            }
            
            guard let result = result,
                sessionDict = result["session"] as? [String: AnyObject],
                sessionID = sessionDict["id"] as? String else {
                    
                    self.updateInfoLabel("Login failed. Try again later.")
                    return
            }
            
            self.otmClient.udacitySessionID = sessionID
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("UserLoggedIn", sender: nil)
            }
        }
    }
}

