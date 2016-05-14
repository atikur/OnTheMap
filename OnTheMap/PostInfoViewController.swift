//
//  PostInfoViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/13/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit
import MapKit

class PostInfoViewController: UIViewController, UITextViewDelegate {
    
    let otmClient = OTMClient.sharedInstance()
    
    let locationTextViewPlaceholderText = "Enter Your Location Here"
    let linkTextViewPlaceholderText = "Enter a Link to Share Here"
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func findOnMapButtonPressed(sender: UIButton) {
        guard let address = locationTextView.text where !address.isEmpty && address != locationTextViewPlaceholderText else {
            showAlert("Location Empty", message: "Please enter a location.")
            return
        }
        
        showActivityIndicator(true)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            
            guard error == nil else {
                self.showGeocodingError("Geocoding Failed", message: "An error occured. Please try again.")
                return
            }
            
            guard let placemarks = placemarks where !placemarks.isEmpty else {
                self.showGeocodingError("Geocoding Failed", message: "Can't perform geocoding. Please try some other location.")
                return
            }
            
            guard let annotation = self.getAnnotationForPlacemark(placemarks[0]) else {
                self.showGeocodingError("Geocoding Failed", message: "Can't perform geocoding. Please try some other location.")
                return
            }
            
            self.centerMapOnLocaion(placemarks[0].location!)
            self.mapView.addAnnotation(annotation)
            self.configureUI(showMap: true)
            self.showActivityIndicator(false)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(okayAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showGeocodingError(title: String, message: String) {
        showAlert(title, message: message)
        showActivityIndicator(false)
    }
    
    func getAnnotationForPlacemark(placemark: CLPlacemark) -> MKPointAnnotation? {
        let annotation = MKPointAnnotation()
        
        guard let location = placemark.location else {
            return nil
        }
        
        annotation.coordinate = location.coordinate
        annotation.title = stringFromPlacemark(placemark)
        return annotation
    }
    
    func centerMapOnLocaion(location: CLLocation) {
        let regionRedius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2, regionRedius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        
        if let subThroughfare = placemark.subThoroughfare {
            line1 += subThroughfare
        }
        
        if let thoroughfare = placemark.thoroughfare {
            line1 += " \(thoroughfare)"
        }
        
        var line2 = ""
        
        if let locality = placemark.locality {
            line2 += locality
        }
        
        if let administrativeArea = placemark.administrativeArea {
            line2 += " \(administrativeArea)"
        }
        
        if let postalCode = placemark.postalCode {
            line2 += " \(postalCode)"
        }
        
        if line1.isEmpty {
            return line2 + "\n"
        } else {
            return line1 + "\n" + line2
        }
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        getUdacityProfileData {
            profileData, error in
            guard error == nil else {
                print(error)
                return
            }
            
            guard let profileData = profileData else {
                print("no profile data found")
                return
            }
            
            print(profileData)
        }
    }
    
    func getUdacityProfileData(completionHandler: (profileData: (firstName: String, lastName: String)?, error: NSError?) -> Void) {
        guard let userId = otmClient.udacityUserID else {
            
            let userInfo = [NSLocalizedDescriptionKey: "User id not found"]
            let error = NSError(domain: "getUdacityProfileData", code: 1, userInfo: userInfo)
            completionHandler(profileData: nil, error: error)
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userId)")!)
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                completionHandler(profileData: nil, error: error)
                return
            }
            
            guard let userDict = result["user"] as? [String: AnyObject],
                firstName = userDict["first_name"] as? String,
                lastName = userDict["last_name"] as? String else {
                    
                let userInfo = [NSLocalizedDescriptionKey: "Can't parse profile information"]
                let error = NSError(domain: "getUdacityProfileData", code: 1, userInfo: userInfo)
                completionHandler(profileData: nil, error: error)
                return
            }
            
            completionHandler(profileData: (firstName, lastName), error: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        linkTextView.delegate = self
        locationTextView.text = locationTextViewPlaceholderText
        linkTextView.text = linkTextViewPlaceholderText
        findOnMapButton.layer.cornerRadius = 10
        activityIndicator.hidden = true
        
        configureUI(showMap: false)
    }
    
    func configureUI(showMap showMap: Bool) {
        linkTextView.hidden = !showMap
        mapView.hidden = !showMap
        submitButton.hidden = !showMap
    }
    
    func showActivityIndicator(show: Bool) {
        activityIndicator.hidden = !show
        
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == locationTextViewPlaceholderText || textView.text == linkTextViewPlaceholderText {
            textView.text = ""
        }
    }
}
