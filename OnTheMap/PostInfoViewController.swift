//
//  PostInfoViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/13/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit
import MapKit

class PostInfoViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var linkTextView: UITextView!
    
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properteis
    
    let otmClient = OTMClient.sharedInstance()
    
    let locationTextViewPlaceholderText = "Enter Your Location Here"
    let linkTextViewPlaceholderText = "Enter a Link to Share Here"
    
    var locationString: String!
    var locationCoordinate: CLLocationCoordinate2D!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        linkTextView.delegate = self
        
        locationTextView.text = locationTextViewPlaceholderText
        linkTextView.text = linkTextViewPlaceholderText
        
        findOnMapButton.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
        
        activityIndicator.hidden = true
        configureUI(showMap: false)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapButtonPressed(sender: UIButton) {
        guard let address = locationTextView.text
            where !address.isEmpty && address != locationTextViewPlaceholderText else {
            
                OTMClient.showAlert(self, title: "Location Empty", message: "Please enter a location.")
                return
        }
        
        findOnTheMap(address)
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        guard let mediaUrl = linkTextView.text
            where !mediaUrl.isEmpty && mediaUrl != linkTextViewPlaceholderText else {
                
                OTMClient.showAlert(self, title: "No Media URL", message: "Please enter media URL.")
                return
        }
        
        submitStudentDataWithMediaUrl(mediaUrl)
    }
    
    // MARK: -
    
    func findOnTheMap(address: String) {
        showActivityIndicator(true)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            
            guard error == nil else {
                self.showError("Geocoding Failed", message: "An error occured. Please try again.")
                return
            }
            
            guard let placemarks = placemarks where !placemarks.isEmpty else {
                self.showError("Geocoding Failed", message: "Can't perform geocoding. Please try some other location.")
                return
            }
            
            guard let annotation = self.getAnnotationForPlacemark(placemarks[0]) else {
                self.showError("Geocoding Failed", message: "Can't perform geocoding. Please try some other location.")
                return
            }
            
            self.centerMapOnLocaion(placemarks[0].location!)
            self.mapView.addAnnotation(annotation)
            
            self.configureUI(showMap: true)
            self.showActivityIndicator(false)
            
            self.locationString = address
            self.locationCoordinate = placemarks[0].location!.coordinate
        }
    }
    
    func submitStudentDataWithMediaUrl(mediaUrl: String) {
        getUdacityProfileData {
            profileData, error in
            
            guard error == nil else {
                print(error)
                self.showError("Error", message: "Can't post student information.")
                return
            }
            
            guard let profileData = profileData else {
                self.showError("Error", message: "Can't post student information.")
                return
            }
            
            let studentInfoDict: [String : AnyObject] = [
                OTMClient.StudentLocationKeys.UniqueKey: self.otmClient.udacityUserID!,
                OTMClient.StudentLocationKeys.FirstName: profileData.firstName,
                OTMClient.StudentLocationKeys.LastName: profileData.lastName,
                OTMClient.StudentLocationKeys.MapString: self.locationString,
                OTMClient.StudentLocationKeys.MediaURL: mediaUrl,
                OTMClient.StudentLocationKeys.Latitude: self.locationCoordinate.latitude,
                OTMClient.StudentLocationKeys.Longitude: self.locationCoordinate.longitude
            ]
            
            let studentInfo = StudentInformation(dictionary: studentInfoDict)
            self.postStudentInformation(studentInfo)
        }
    }
    
    func postStudentInformation(studentInfo: StudentInformation) {
        let request = OTMClient.requestForPostingStudentInfo(studentInfo)
        
        otmClient.taskForRequest(request, isUdacityAPI: false) {
            result, error in
            
            guard error == nil else {
                print(error)
                self.showError("Error", message: "Can't post student information.")
                return
            }
            
            guard let result = result else {
                self.showError("Error", message: "Can't post student information.")
                return
            }
            
            guard let objectId = result["objectId"] else {
                self.showError("Error", message: "Can't post student information.")
                return
            }
            
            print("Successfully posted: \(objectId)")
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let navController = (self.presentingViewController as? UITabBarController)?.selectedViewController as? UINavigationController {
                    if let presenter = navController.viewControllers[0] as? StudentMapViewController {
                        presenter.refreshMapAnnotations()
                    } else if let presenter = navController.viewControllers[0] as? StudentListViewController {
                        OTMClient.getStudentInfoWithViewController(presenter)
                    }
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func getUdacityProfileData(completionHandler: (profileData: (firstName: String, lastName: String)?, error: NSError?) -> Void) {
        
        func sendError(message: String) -> NSError {
            let userInfo = [NSLocalizedDescriptionKey: message]
            let error = NSError(domain: "getUdacityProfileData", code: 1, userInfo: userInfo)
            return error
        }
        
        guard let userId = otmClient.udacityUserID else {
            completionHandler(profileData: nil, error: sendError("User id not found"))
            return
        }
        
        let request = OTMClient.requestForUdacityProfileDataRetrieval(userId)
        
        otmClient.taskForRequest(request, isUdacityAPI: true) {
            result, error in
            
            guard error == nil else {
                completionHandler(profileData: nil, error: error)
                return
            }
            
            guard let userDict = result["user"] as? [String: AnyObject],
                firstName = userDict["first_name"] as? String,
                lastName = userDict["last_name"] as? String else {

                    completionHandler(profileData: nil, error: sendError("Can't parse profile information"))
                    return
            }
            
            completionHandler(profileData: (firstName, lastName), error: nil)
        }
    }
    
    // MARK: - Helpers
    
    func centerMapOnLocaion(location: CLLocation) {
        let regionRedius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRedius * 2, regionRedius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
    func showError(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            OTMClient.showAlert(self, title: title, message: message)
            self.showActivityIndicator(false)
        }
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
    
    // MARK: - Configure UI Controls
    
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
    
    // MARK: -
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        locationTextView.resignFirstResponder()
        linkTextView.resignFirstResponder()
    }
}

extension PostInfoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == locationTextViewPlaceholderText || textView.text == linkTextViewPlaceholderText {
            textView.text = ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
