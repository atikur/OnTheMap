//
//  OTMStudentLocation.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import Foundation

struct OTMStudentLocation {
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    
    init(dicationary: [String: AnyObject]) {
        objectId = dicationary[OTMClient.StudentLocationKeys.ObjectId] as! String
        uniqueKey = dicationary[OTMClient.StudentLocationKeys.UniqueKey] as! String
        firstName = dicationary[OTMClient.StudentLocationKeys.FirstName] as! String
        lastName = dicationary[OTMClient.StudentLocationKeys.LastName] as! String
        mapString = dicationary[OTMClient.StudentLocationKeys.MapString] as! String
        mediaURL = dicationary[OTMClient.StudentLocationKeys.MediaURL] as! String
        latitude = dicationary[OTMClient.StudentLocationKeys.Latitude] as! Float
        longitude = dicationary[OTMClient.StudentLocationKeys.Longitude] as! Float
    }
    
    static func studentLocationFromResults(results: [[String: AnyObject]]) -> [OTMStudentLocation] {
        var locations = [OTMStudentLocation]()
        
        for result in results {
            locations.append(OTMStudentLocation(dicationary: result))
        }
        
        return locations
    }
    
}
