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
    
    let textViewPlaceholderText = "Enter Your Location Here"
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findOnMapButton: UIButton!
    
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
                return
            }
            
            print(placemarks[0])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self
        locationTextView.text = textViewPlaceholderText
        findOnMapButton.layer.cornerRadius = 10
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == textViewPlaceholderText {
            textView.text = ""
        }
    }
}
