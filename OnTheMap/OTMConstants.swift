//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

public let DidReceiveStudentInfoNotification = "DidReceiveStudentInfoNotification"

extension OTMClient {
    
    struct Constants {
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    struct StudentLocationKeys {
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let Acl = "ACL"
    }
    
    struct UdacityURL {
        static let Auth = "https://www.udacity.com/api/session"
        static let UserProfile = "https://www.udacity.com/api/users/{id}"
    }
    
    struct ParseURL {
        static let StudentLocation = "https://api.parse.com/1/classes/StudentLocation"
    }
    
}
