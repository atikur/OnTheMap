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
    
    let otmClient = OTMClient.sharedInstance()
    
    // MARK: - Actions
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        guard let email = emailTextField.text,
            password = passwordTextField.text
            where !email.isEmpty && !password.isEmpty else {
                
                OTMClient.showAlert(self, title: "Error", message: "Email/password field empty.")
                return
        }
        
        loginWithEmail(email, password: password)
    }
    
    // MARK: -
    
    func loginWithEmail(email: String, password: String) {
        let request = OTMClient.requestForUdacityLogin(email, password: password)
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.showLoginError("Wrong email or password.")
                return
            }
            
            guard let result = result,
                accountDict = result["account"] as? [String: AnyObject],
                sessionDict = result["session"] as? [String: AnyObject],
                userID = accountDict["key"] as? String,
                sessionID = sessionDict["id"] as? String else {
                    
                    self.showLoginError("Can't process the request. Try again later!")
                    return
            }
                        
            self.otmClient.udacitySessionID = sessionID
            self.otmClient.udacityUserID = userID
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("UserLoggedIn", sender: nil)
            }
        }
    }
    
    func showLoginError(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            OTMClient.showAlert(self, title: "Login Failed", message: message)
        }
    }
}

