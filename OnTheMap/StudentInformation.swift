//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import MapKit

struct StudentInformation {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    
    var location: CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    init(dictionary: [String: AnyObject]) {
        uniqueKey = dictionary[OTMClient.StudentLocationKeys.UniqueKey] as! String
        firstName = dictionary[OTMClient.StudentLocationKeys.FirstName] as! String
        lastName = dictionary[OTMClient.StudentLocationKeys.LastName] as! String
        mapString = dictionary[OTMClient.StudentLocationKeys.MapString] as! String
        mediaURL = dictionary[OTMClient.StudentLocationKeys.MediaURL] as! String
        latitude = dictionary[OTMClient.StudentLocationKeys.Latitude] as! Float
        longitude = dictionary[OTMClient.StudentLocationKeys.Longitude] as! Float
    }
    
    static func studentInformationFromResults(results: [[String: AnyObject]]) -> [StudentInformation] {
        var studentList = [StudentInformation]()
        
        for result in results {
            studentList.append(StudentInformation(dictionary: result))
        }
        
        return studentList
    }
    
}
