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
                completionHandler(result: nil, error: error)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // because Udacity API return status code 403 for wrong username/password
            if !isUdacityAPI {
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    sendError("Your request returned a status code other than 2xx!")
                    return
                }
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
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInsance = OTMClient()
        }
        return Singleton.sharedInsance
    }
    
}
