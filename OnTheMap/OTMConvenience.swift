//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/15/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient {
    
    func authenticate(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = OTMClient.requestForUdacityLogin(username, password: password)
        
        taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
                        
            guard let result = result,
                accountDict = result["account"] as? [String: AnyObject],
                sessionDict = result["session"] as? [String: AnyObject],
                userID = accountDict["key"] as? String,
                sessionID = sessionDict["id"] as? String else {
                    
                    completionHandler(success: false, errorString: "Wrong email or password.")
                    return
            }
            
            self.udacitySessionID = sessionID
            self.udacityUserID = userID
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    func getStudentInformation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = OTMClient.requestForStudentInfoRetrieval()
        
        taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            
            guard let result = result,
                studentInfoResults = result["results"] as? [[String: AnyObject]] else {
                    
                    completionHandler(success: false, errorString: "Can't get student information.")
                    return
            }
            
            OTMModel.sharedInstance().studentList = StudentInformation.studentInformationFromResults(studentInfoResults)
            completionHandler(success: true, errorString: nil)
        }
    }
    
    func logout(completionHandler: (success: Bool, errorString: String?) -> Void)  {
        let request = OTMClient.requestForUdacityLogout()
        
        taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            
            guard let result = result,
                sessionDict = result["session"] as? [String: AnyObject],
                sessionID = sessionDict["id"] as? String else {
                    
                    completionHandler(success: false, errorString: "An error occurred. Try again later.")
                    return
            }
            
            self.udacitySessionID = nil
            self.udacityUserID = nil
            OTMModel.sharedInstance().studentList = []
            
            print("logged out successfully: \(sessionID)")
            completionHandler(success: true, errorString: nil)
        }
    }
    
}
