//
//  PostInfoViewController.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/13/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

class PostInfoViewController: UIViewController, UITextViewDelegate {
    
    let textViewPlaceholderText = "Enter Your Location Here"
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func findOnMapButtonPressed(sender: UIButton) {
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
