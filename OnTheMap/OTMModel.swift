//
//  OTMModel.swift
//  OnTheMap
//
//  Created by Atikur Rahman on 5/15/16.
//  Copyright © 2016 Atikur Rahman. All rights reserved.
//

import Foundation

class OTMModel {
    
    var studentList = [StudentInformation]()
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> OTMModel {
        struct Singleton {
            static var sharedInsance = OTMModel()
        }
        return Singleton.sharedInsance
    }
    
}
