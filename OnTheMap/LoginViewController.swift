//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/11/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    
    let otmClient = OTMClient.sharedInstance()
    
    // MARK: - Actions
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        guard let email = emailTextField.text, password = passwordTextField.text where !email.isEmpty && !password.isEmpty else {
            infoLabel.text = "Email/password field empty."
            return
        }
        
        loginWithEmail(email, password: password)
    }
    
    // MARK: - Lifecyle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoLabel.text = ""
    }
    
    // MARK: -
    
    func updateInfoLabel(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.infoLabel.text = message
        }
    }
    
    func loginWithEmail(email: String, password: String) {
        let request = OTMClient.postRequestForUdacityLogin(email, password: password)
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.updateInfoLabel("Wrong email/password.")
                return
            }
            
            guard let result = result,
                accountDict = result["account"] as? [String: AnyObject],
                sessionDict = result["session"] as? [String: AnyObject],
                userID = accountDict["key"] as? String,
                sessionID = sessionDict["id"] as? String else {
                    
                    self.updateInfoLabel("Login failed. Try again later.")
                    return
            }
                        
            self.otmClient.udacitySessionID = sessionID
            self.otmClient.udacityUserID = userID
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("UserLoggedIn", sender: nil)
            }
        }
    }
}

