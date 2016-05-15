//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import Foundation

class OTMClient: NSObject {
    
    // MARK: - Properteis
    
    let session = NSURLSession.sharedSession()
    var studentList = [StudentInformation]()

    var udacitySessionID: String?
    var udacityUserID: String?
    
    // MARK: - 
    
    func taskForRequest(request: NSURLRequest, isUdacityAPI: Bool, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            func sendError(errorString: String) {
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                completionHandler(result: nil, error: NSError(domain: "taskForHTTPRequest", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let newData = isUdacityAPI ? data.subdataWithRange(NSMakeRange(5, data.length - 5)) : data
            self.parseDataWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    func parseDataWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch {
            let uesrInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON"]
            completionHandler(result: nil, error: NSError(domain: "parseDataWithCompletionHandler", code: 1, userInfo: uesrInfo))
        }
    }
    
    func substituteKeyInURLString(urlString: String, key: String, value: String) -> String? {
        if urlString.rangeOfString("{\(key)}") != nil {
            return urlString.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // MARK: - NSURLRequests
    
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
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInsance = OTMClient()
        }
        return Singleton.sharedInsance
    }
    
}
