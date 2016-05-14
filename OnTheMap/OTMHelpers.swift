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
    
}
