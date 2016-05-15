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
                completionHandler(success: false, errorString: "Wrong email or password")
                return
            }
            
            guard let result = result,
                accountDict = result["account"] as? [String: AnyObject],
                sessionDict = result["session"] as? [String: AnyObject],
                userID = accountDict["key"] as? String,
                sessionID = sessionDict["id"] as? String else {
                    
                    completionHandler(success: false, errorString: "Can't process the request. Try again later!")
                    return
            }
            
            self.udacitySessionID = sessionID
            self.udacityUserID = userID
            
            completionHandler(success: true, errorString: nil)
        }
    }
    
}
