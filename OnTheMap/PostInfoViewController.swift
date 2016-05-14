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
    
    let locationTextViewPlaceholderText = "Enter Your Location Here"
    let linkTextViewPlaceholderText = "Enter a Link to Share Here"
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func findOnMapButtonPressed(sender: UIButton) {
        guard let address = locationTextView.text else {
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            
            guard error == nil else {
                print(error)
                return
            }
            
            guard let placemarks = placemarks where !placemarks.isEmpty else {
                print("no placemark found!")
                return
            }
            
            guard let annotation = self.getAnnotationForPlacemark(placemarks[0]) else {
                print("can't get annotation for placemark")
                return
            }
            
            self.centerMapOnLocaion(placemarks[0].location!)
            self.mapView.addAnnotation(annotation)
            self.configureUI(showMap: true)
        }
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        linkTextView.delegate = self
        locationTextView.text = locationTextViewPlaceholderText
        linkTextView.text = linkTextViewPlaceholderText
        findOnMapButton.layer.cornerRadius = 10
        
        configureUI(showMap: false)
    }
    
    func configureUI(showMap showMap: Bool) {
        linkTextView.hidden = !showMap
        mapView.hidden = !showMap
        submitButton.hidden = !showMap
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == locationTextViewPlaceholderText || textView.text == linkTextViewPlaceholderText {
            textView.text = ""
        }
    }
}
