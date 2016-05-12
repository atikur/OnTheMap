//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var initialLocation: CLLocation!
    let regionRedius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialLocation = CLLocation(latitude: 37.3230, longitude: -122.0322)
        centerMapOnLocaion(initialLocation)
    }
    
    func centerMapOnLocaion(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2, regionRedius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}
