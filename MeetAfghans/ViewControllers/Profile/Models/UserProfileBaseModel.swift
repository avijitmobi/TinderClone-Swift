//
//  UserProfileBaseModel.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 16/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation

public class UserProfileBaseModel {
    public var jsonrpc : String?
    public var result : UserProfileResult?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UserProfileBaseModel]
    {
        var models:[UserProfileBaseModel] = []
        for item in array
        {
            models.append(UserProfileBaseModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["result"] != nil) { result = UserProfileResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}

public class UserProfileResult {
    public var user_img : Array<UserImageModel>?
    public var user : UserDataModel?
    public var age : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UserProfileResult]
    {
        var models:[UserProfileResult] = []
        for item in array
        {
            models.append(UserProfileResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        age = (dictionary["age"] as? NSNumber)?.description ?? (dictionary["age"] as? String)
        if (dictionary["user_img"] != nil) { user_img = UserImageModel.modelsFromDictionaryArray(array: dictionary["user_img"] as? NSArray ?? NSArray()) }
        if (dictionary["user"] != nil) { user = UserDataModel(dictionary: dictionary["user"] as? NSDictionary ?? NSDictionary()) }
    }
    
}

public class UserImageModel {
    public var id : String?
    public var user_id : String?
    public var file_order : Int?
    public var file_name : String?
    public var is_instagram_connected : String?
    public var created_at : String?
    public var updated_at : String?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UserImageModel]
    {
        var models:[UserImageModel] = []
        for item in array
        {
            models.append(UserImageModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        user_id = (dictionary["user_id"] as? NSNumber)?.description ?? (dictionary["user_id"] as? String)
        file_order = (dictionary["file_order"] as? NSNumber)?.intValue ?? NSString(string :(dictionary["id"] as? String ?? "")).integerValue
        file_name = dictionary["file_name"] as? String
        is_instagram_connected = dictionary["is_instagram_connected"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
    }
    
}
