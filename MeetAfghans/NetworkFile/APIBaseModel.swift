//
//  EMBaseModel.swift
//  AlmoFire API Calling Example
//
//  Created by Hasya.Panchasara on 03/11/17.
//  Copyright © 2017 Hasya Panchasara. All rights reserved.
//


import Foundation

struct APIResponseStatusKeys {
    static let success = "success"
    static let message = "message"
    static let status = "status"
    static let data = "data"
    static let tokenData = "tokendata"
}

class APIBaseModel {
    

    var status: String?
    var success: String?
    var message : String?
    
    init(jsonDict: Dictionary<String, AnyObject>) {
        
        self.status = jsonDict[APIResponseStatusKeys.status] as? String
        self.message = jsonDict[APIResponseStatusKeys.message] as? String
    }
}

class APIResponseModel {
    
    var status: String?
    var success: String?
    var message : String?
    var data : Dictionary<String,AnyObject>?
    var tokenData : Dictionary<String,AnyObject>?
    
    init(jsonDict: Dictionary<String, AnyObject>) {
        
        self.status = jsonDict[APIResponseStatusKeys.status] as? String
        self.message = jsonDict[APIResponseStatusKeys.message] as? String
        
        if(self.status == APIResponseStatusKeys.success){
            data = jsonDict[APIResponseStatusKeys.data] as? Dictionary<String,AnyObject>
        }
        
        if jsonDict[APIResponseStatusKeys.tokenData] != nil {
            tokenData = jsonDict[APIResponseStatusKeys.tokenData] as? Dictionary<String,AnyObject>
        }
        
    }
}


