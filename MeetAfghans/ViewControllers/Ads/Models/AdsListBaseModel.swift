//
//  AdsListBaseModel.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 07/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation


public class AdsListBaseModel {
    
    public var jsonrpc : String?
    public var my_ads : Array<MyAdsList>?
    public var result : MyAdsResult?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [AdsListBaseModel]
    {
        var models:[AdsListBaseModel] = []
        for item in array
        {
            models.append(AdsListBaseModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["my_ads"] != nil) { my_ads = MyAdsList.modelsFromDictionaryArray(array: dictionary["my_ads"] as? NSArray ?? NSArray()) }
        if (dictionary["result"] != nil) { result = MyAdsResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}


public class MyAdsResult {
    public var code : String?
    public var message : String?
    public var meaning : String?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [MyAdsResult]
    {
        var models:[MyAdsResult] = []
        for item in array
        {
            models.append(MyAdsResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        code = dictionary["code"] as? String
        message = dictionary["message"] as? String
        meaning = dictionary["meaning"] as? String
    }
    
}


public class MyAdsList {
    public var id : String?
    public var user_id : String?
    public var business_name : String?
    public var package_duration : String?
    public var company : String?
    public var mobile : String?
    public var email : String?
    public var url : String?
    public var description : String?
    public var file_name : String?
    public var package_price : String?
    public var created_at : String?
    public var updated_at : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [MyAdsList]
    {
        var models:[MyAdsList] = []
        for item in array
        {
            models.append(MyAdsList(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        user_id = (dictionary["user_id"] as? NSNumber)?.description ?? (dictionary["user_id"] as? String)
        business_name = dictionary["business_name"] as? String
        package_duration = (dictionary["package_duration"] as? NSNumber)?.description ?? (dictionary["package_duration"] as? String)
        company = dictionary["company"] as? String
        mobile = dictionary["mobile"] as? String
        email = dictionary["email"] as? String
        url = dictionary["url"] as? String
        description = dictionary["description"] as? String
        file_name = dictionary["file_name"] as? String
        package_price = dictionary["package_price"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
    }
    
    
}
