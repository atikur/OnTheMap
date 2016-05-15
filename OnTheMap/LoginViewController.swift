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
        otmClient.authenticate(email, password: password) {
            success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.completeLogin()
                } else {
                    self.showLoginError(errorString)
                }
            }
        }
    }
    
    func completeLogin() {
        self.performSegueWithIdentifier("UserLoggedIn", sender: nil)
    }
    
    func showLoginError(message: String?) {
        if let message = message {
            OTMClient.showAlert(self, title: "Login Failed", message: message)
        }
    }
}

