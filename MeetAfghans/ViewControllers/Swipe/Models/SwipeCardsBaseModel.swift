//
//  SwipeCardsBaseModel.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 19/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation


public class SwipeCardsBaseModel {
    public var jsonrpc : String?
    public var result : SwipeCardsResult?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [SwipeCardsBaseModel]
    {
        var models:[SwipeCardsBaseModel] = []
        for item in array
        {
            models.append(SwipeCardsBaseModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["result"] != nil) { result = SwipeCardsResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}


public class SwipeCardsResult {
    public var user : Array<UserDataModel>?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [SwipeCardsResult]
    {
        var models:[SwipeCardsResult] = []
        for item in array
        {
            models.append(SwipeCardsResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        if (dictionary["user"] != nil) { user = UserDataModel.modelsFromDictionaryArray(array: dictionary["user"] as? NSArray ?? NSArray()) }
    }
    
    
}
