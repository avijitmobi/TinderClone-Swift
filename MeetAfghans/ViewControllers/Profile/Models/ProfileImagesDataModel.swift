//
//  ProfileImagesDataModel.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 16/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation

public class ProfileImagesDataModel {
    public var jsonrpc : String?
    public var user_file_data : Array<UsersImageData>?
    public var result : UsersImagesResult?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [ProfileImagesDataModel]
    {
        var models:[ProfileImagesDataModel] = []
        for item in array
        {
            models.append(ProfileImagesDataModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["user_file_data"] != nil) { user_file_data = UsersImageData.modelsFromDictionaryArray(array: dictionary["user_file_data"] as? NSArray ?? NSArray()) }
        if (dictionary["result"] != nil) { result = UsersImagesResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}


public class UsersImagesResult {
    public var code : String?
    public var message : String?
    public var meaning : String?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UsersImagesResult]
    {
        var models:[UsersImagesResult] = []
        for item in array
        {
            models.append(UsersImagesResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        code = dictionary["code"] as? String
        message = dictionary["message"] as? String
        meaning = dictionary["meaning"] as? String
    }
    
}


public class UsersImageData {
    public var id : Int?
    public var user_id : Int?
    public var file_order : Int?
    public var file_name : String?
    public var is_instagram_connected : String?
    public var created_at : String?
    public var updated_at : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UsersImageData]
    {
        var models:[UsersImageData] = []
        for item in array
        {
            models.append(UsersImageData(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {
        
        id = (dictionary["id"] as? NSNumber)?.intValue ?? NSString(string : dictionary["id"] as? String ?? "").integerValue
        user_id = dictionary["user_id"] as? Int
        file_order = (dictionary["file_order"] as? NSNumber)?.intValue ?? NSString(string : dictionary["file_order"] as? String ?? "").integerValue
        file_name = dictionary["file_name"] as? String
        is_instagram_connected = dictionary["is_instagram_connected"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
    }
    
}
