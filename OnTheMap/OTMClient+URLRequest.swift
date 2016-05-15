//
//  OTMClient+URLRequest.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/15/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import Foundation

extension OTMClient {
        
    class func requestForUdacityProfileDataRetrieval(userId: String) -> NSURLRequest {
        let urlString = OTMClient.sharedInstance().substituteKeyInURLString(UdacityURL.UserProfile, key: "id", value: userId)
        
        return NSMutableURLRequest(URL: NSURL(string: urlString!)!)
    }
    
    class func requestForStudentInfoRetrieval() -> NSURLRequest {
        let url = NSURL(string: "\(ParseURL.StudentLocation)?limit=100&order=-updatedAt")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request
    }
    
    class func requestForPostingStudentInfo(studentInfo: StudentInformation) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: ParseURL.StudentLocation)!)
        
        request.HTTPMethod = "POST"
        
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(studentInfo.uniqueKey)\", \"firstName\": \"\(studentInfo.firstName)\", \"lastName\": \"\(studentInfo.lastName)\",\"mapString\": \"\(studentInfo.mapString)\", \"mediaURL\": \"\(studentInfo.mediaURL)\",\"latitude\": \(studentInfo.latitude), \"longitude\": \(studentInfo.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
    class func requestForUdacityLogin(username: String, password: String) -> NSURLRequest {
        let url = NSURL(string: UdacityURL.Auth)!
        let requestBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = requestBody
        
        return request
    }
    
    class func requestForUdacityLogout() -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityURL.Auth)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        return request
    }
}
