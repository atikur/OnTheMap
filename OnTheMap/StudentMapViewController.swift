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
        dispatch_async(dispatch_get_main_queue()) {
            let studentLocations = self.otmClient.studentList.map { self.getStudentAnnotation($0) }
            self.mapView.addAnnotations(studentLocations)
            
            self.mapView.showAnnotations([studentLocations[0]], animated: true)
        }
    }
    
    func getStudentAnnotation(studentInfo: StudentInformation) -> StudentAnnotation {
        return StudentAnnotation(name: studentInfo.firstName + " " + studentInfo.lastName, mediaURL: studentInfo.mediaURL, coordinate: studentInfo.location.coordinate)
    }
    
    // MARK: -
    
    func logout() {
        otmClient.logout {
            success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.displayError("Logout Failed", message: errorString)
                }
            }
        }
    }
    
    func getStudentInfo() {
        otmClient.getStudentInformation {
            success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    NSNotificationCenter.defaultCenter().postNotificationName(DidReceiveStudentInfoNotification, object: nil)
                } else {
                    self.displayError("Error", message: errorString)
                }
            }
        }
    }
    
    func displayError(title: String, message: String?) {
        if let message = message {
            OTMClient.showAlert(self, title: title, message: message)
        }
    }
    
    func refreshMapAnnotations() {
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        getStudentInfo()
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

