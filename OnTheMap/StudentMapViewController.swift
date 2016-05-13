//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/12/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var initialLocation: CLLocation!
    let regionRedius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        initialLocation = CLLocation(latitude: 37.3230, longitude: -122.0322)
        centerMapOnLocaion(initialLocation)
        
        let sampleAnnotation = StudentLocation(name: "John Doe", mediaURL: "http://www.example.com", coordinate: CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322))
        mapView.addAnnotation(sampleAnnotation)
    }
    
    func centerMapOnLocaion(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2, regionRedius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? StudentLocation else {
            return nil
        }
        
        let identifier = "studentLocationPin"
        let view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPointMake(-5, 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? StudentLocation else {
            return
        }
        
        guard let url = NSURL(string: annotation.mediaURL) else {
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
    }
    
}
