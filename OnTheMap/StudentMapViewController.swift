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
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    let otmClient = OTMClient.sharedInstance()
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        logout()
    }
    
    // MARK: -
    
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
    
    func getStudentAnnotation(studentInfo: StudentInformation) -> StudentAnnotation {
        return StudentAnnotation(name: studentInfo.firstName + " " + studentInfo.lastName, mediaURL: studentInfo.mediaURL, coordinate: studentInfo.location.coordinate)
    }
    
    // MARK: -
    
    func logout() {
        let request = OTMClient.requestForUdacityLogout()
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.displayError("Logout Failed", message: "An error occurred. Try again later.")
                return
            }
            
            guard let result = result,
                sessionDict = result["session"] as? [String: AnyObject],
                sessionID = sessionDict["id"] as? String else {
                    self.displayError("Logout Failed", message: "An error occurred. Try again later.")
                    return
            }
            
            self.otmClient.udacitySessionID = nil
            self.otmClient.udacityUserID = nil
            self.otmClient.studentList = []
            
            print("logged out successfully: \(sessionID)")
            
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func getStudentInfo() {
        let request = OTMClient.requestForStudentInfoRetrieval()
        
        otmClient.taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.displayError("Error", message: "Can't get student information.")
                return
            }
            
            guard let result = result, studentInfoResults = result["results"] as? [[String: AnyObject]] else {
                self.displayError("Error", message: "Can't get student information.")
                return
            }
            
            self.otmClient.studentList = StudentInformation.studentInformationFromResults(studentInfoResults)
            NSNotificationCenter.defaultCenter().postNotificationName(DidReceiveStudentInfoNotification, object: nil)
        }
    }
    
    func displayError(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            OTMClient.showAlert(self, title: title, message: message)
        }
    }
    
    // MARK: -
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension StudentMapViewController: MKMapViewDelegate {
    
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
}

