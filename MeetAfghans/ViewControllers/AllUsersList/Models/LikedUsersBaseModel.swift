//
//  LikedUsersBaseModel.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 24/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation


public class LikedUserBaseModel {
    public var jsonrpc : String?
    public var user_like_list : Array<User_like_list>?
    
   
    public class func modelsFromDictionaryArray(array:NSArray) -> [LikedUserBaseModel]
    {
        var models:[LikedUserBaseModel] = []
        for item in array
        {
            models.append(LikedUserBaseModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["user_like_list"] != nil) { user_like_list = User_like_list.modelsFromDictionaryArray(array: dictionary["user_like_list"] as? NSArray ?? NSArray()) }
    }
    
}


public class User_like_list {
    public var id : String?
    public var from_id : Int?
    public var to_id : Int?
    public var like_status : String?
    public var block_status : String?
    public var created_at : String?
    public var updated_at : String?
    public var get_user : UserDataModel?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [User_like_list]
    {
        var models:[User_like_list] = []
        for item in array
        {
            models.append(User_like_list(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    
    required public init?(dictionary: NSDictionary) {
        
        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        from_id = dictionary["from_id"] as? Int
        to_id = dictionary["to_id"] as? Int
        like_status = dictionary["like_status"] as? String
        block_status = dictionary["block_status"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
        if (dictionary["get_user"] != nil) { get_user = UserDataModel(dictionary: dictionary["get_user"] as? NSDictionary ?? NSDictionary()) }
    }
    
}
