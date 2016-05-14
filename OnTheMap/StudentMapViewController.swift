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
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logout()
    }
    
    @IBAction func pinButtonPressed(sender: UIBarButtonItem) {
        
    }
    
    func logout() {
        let request = OTMClient.deleteRequestForUdacityLogout()
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let result = result,
                sessionDict = result["session"] as? [String: AnyObject],
                sessionID = sessionDict["id"] as? String else {
                    return
            }
            
            self.otmClient.udacitySessionID = nil
            self.otmClient.udacityUserID = nil
            self.otmClient.studentList = []
            
            print("logged out successfully!")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentInfo()
        
        mapView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StudentMapViewController.studentInfoReceived), name: DidReceiveStudentInfoNotification, object: nil)
    }
    
    func studentInfoReceived() {
        let studentLocations = otmClient.studentList.map { self.getStudentAnnotation($0) }
        mapView.addAnnotations(studentLocations)
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
            NSNotificationCenter.defaultCenter().postNotificationName(DidReceiveStudentInfoNotification, object: nil)
        }
    }
    
    // MARK: - Helpers
    
    func centerMapOnLocaion(location: CLLocation) {
        let regionRedius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2, regionRedius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getStudentAnnotation(studentInfo: StudentInformation) -> StudentAnnotation {
        return StudentAnnotation(name: studentInfo.firstName + " " + studentInfo.lastName, mediaURL: studentInfo.mediaURL, coordinate: studentInfo.location.coordinate)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? StudentAnnotation else {
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
        guard let annotation = view.annotation as? StudentAnnotation else {
            return
        }
        
        guard let url = NSURL(string: annotation.mediaURL) else {
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
