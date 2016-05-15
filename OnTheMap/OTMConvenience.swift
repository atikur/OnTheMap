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
    
    func submitStudentInformationToParse(studentInfoDict: [String : AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var studentDict = studentInfoDict
        
        getUdacityProfileData {
            profileData, errorString in
            
            guard let profileData = profileData else {
                completionHandler(success: false, errorString: errorString)
                return
            }
            
            studentDict[StudentLocationKeys.FirstName] = profileData.firstName
            studentDict[StudentLocationKeys.LastName] = profileData.lastName
            
            let studentInfo = StudentInformation(dictionary: studentDict)
            self.postStudentInformation(studentInfo, completionHandler: completionHandler)
        }
    }
    
    private func postStudentInformation(studentInfo: StudentInformation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = OTMClient.requestForPostingStudentInfo(studentInfo)
        
        taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            
            guard let result = result else {
                completionHandler(success: false, errorString: "Can't post student information.")
                return
            }
            
            guard let objectId = result["objectId"] else {
                completionHandler(success: false, errorString: "Can't post student information.")
                return
            }
            
            print("Successfully posted: \(objectId)")
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
    private func getUdacityProfileData(completionHandler: (profileData: (firstName: String, lastName: String)?, errorString: String?) -> Void) {
        
        guard let userId = udacityUserID else {
            completionHandler(profileData: nil, errorString: "Can't get user data.")
            return
        }
        
        let request = OTMClient.requestForUdacityProfileDataRetrieval(userId)
        
        taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                completionHandler(profileData: nil, errorString: error?.localizedDescription)
                return
            }
            
            guard let userDict = result["user"] as? [String: AnyObject],
                firstName = userDict["first_name"] as? String,
                lastName = userDict["last_name"] as? String else {
                    
                    completionHandler(profileData: nil, errorString: "Can't get user data.")
                    return
            }
            
            completionHandler(profileData: (firstName, lastName), errorString: nil)
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
