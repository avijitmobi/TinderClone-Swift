//
//  ChatDetailsModel.swift
//  MeetAfghans
//
//  Created by SAM AI on 29/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation


public class ChatDetailsModel {
    public var jsonrpc : String?
    public var result : ChatDetailsResult?

    public class func modelsFromDictionaryArray(array:NSArray) -> [ChatDetailsModel]
    {
        var models:[ChatDetailsModel] = []
        for item in array
        {
            models.append(ChatDetailsModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {

        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["result"] != nil) { result = ChatDetailsResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }

}


public class ChatDetailsResult {
    public var user : UserDataModel?
    public var chat_list : Array<Chat_details_model>?

    public class func modelsFromDictionaryArray(array:NSArray) -> [ChatDetailsResult]
    {
        var models:[ChatDetailsResult] = []
        for item in array
        {
            models.append(ChatDetailsResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {

        if (dictionary["user"] != nil) { user = UserDataModel(dictionary: dictionary["user"] as? NSDictionary ?? NSDictionary()) }
        if (dictionary["chat_list"] != nil) { chat_list = Chat_details_model.modelsFromDictionaryArray(array: dictionary["chat_list"] as? NSArray ?? NSArray()) }
    }

}


public class Chat_details_model {
    
    public var id : String?
    public var chat_id : String?
    public var from_id : String?
    public var to_id : String?
    public var from_message : String?
    public var to_message : String?
    public var from_image : String?
    public var to_image : String?
    public var created_at : String?
    public var updated_at : String?

    public class func modelsFromDictionaryArray(array:NSArray) -> [Chat_details_model]
    {
        var models:[Chat_details_model] = []
        for item in array
        {
            models.append(Chat_details_model(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {

        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        chat_id = (dictionary["chat_id"] as? NSNumber)?.description ?? (dictionary["chat_id"] as? String)
        from_id = (dictionary["from_id"] as? NSNumber)?.description ?? (dictionary["from_id"] as? String)
        to_id = (dictionary["to_id"] as? NSNumber)?.description ?? (dictionary["to_id"] as? String)
        from_message = dictionary["from_message"] as? String
        to_message = dictionary["to_message"] as? String
        from_image = dictionary["from_image"] as? String
        to_image = dictionary["to_image"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
    }

}
