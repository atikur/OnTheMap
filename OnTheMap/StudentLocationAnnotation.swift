//
//  StudentLocationAnnotation.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import MapKit

class StudentLocationAnnotation: NSObject, MKAnnotation {
    
    let name: String
    let mediaURL: String
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, mediaURL: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.mediaURL = mediaURL
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return mediaURL
    }
    
    var title: String? {
        return name
    }
}
