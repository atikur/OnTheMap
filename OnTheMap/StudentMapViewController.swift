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
    
    let otmClient = OTMClient.sharedInstance()
    
    var initialLocation: CLLocation!
    let regionRedius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInfo()
        
        mapView.delegate = self
        
        initialLocation = CLLocation(latitude: 37.3230, longitude: -122.0322)
        centerMapOnLocaion(initialLocation)
        
        let sampleAnnotation = StudentLocation(name: "John Doe", mediaURL: "http://www.example.com", coordinate: CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322))
        mapView.addAnnotation(sampleAnnotation)
    }
    
    func getStudentInfo() {
        let url = NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=50")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        otmClient.taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let result = result, studentInfoResults = result["results"] as? [[String: AnyObject]] else {
                return
            }
            
            self.otmClient.studentList = StudentInformation.studentInformationFromResults(studentInfoResults)
            
            print(self.otmClient.studentList)
        }
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
