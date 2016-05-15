//
//  OTMHelpers.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/14/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import UIKit

extension OTMClient {
    
    class func showAlert(hostVC: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(okayAction)
        hostVC.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func logoutFromViewController(hostVC: UIViewController) {
        OTMClient.sharedInstance().logout {
            success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    hostVC.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    displayError(hostVC, title: "Logout Failed", message: errorString)
                }
            }
        }
    }
    
    class func getStudentInfoWithViewController(hostVC: UIViewController) {
        OTMClient.sharedInstance().getStudentInformation {
            success, errorString in
            
            dispatch_async(dispatch_get_main_queue()) {
                if success {
                    NSNotificationCenter.defaultCenter().postNotificationName(DidReceiveStudentInfoNotification, object: nil)
                } else {
                    displayError(hostVC, title: "Error", message: errorString)
                }
            }
        }
    }
    
    class func displayError(hostVC: UIViewController, title: String, message: String?) {
        if let message = message {
            showAlert(hostVC, title: title, message: message)
        }
    }
}
