//
//  MatchListModel.swift
//  MeetAfghans
//
//  Created by SAM AI on 30/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation


public class MatchListModel {
    public var jsonrpc : String?
    public var match_list : Array<Match_list>?
    public var result : MatchListResult?

    public class func modelsFromDictionaryArray(array:NSArray) -> [MatchListModel]
    {
        var models:[MatchListModel] = []
        for item in array
        {
            models.append(MatchListModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {

        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["match_list"] != nil) { match_list = Match_list.modelsFromDictionaryArray(array: dictionary["match_list"] as? NSArray ?? NSArray()) }
        if (dictionary["result"] != nil) { result = MatchListResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }

}

public class MatchListResult {
    public var code : String?
    public var message : String?
    public var meaning : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [MatchListResult]
    {
        var models:[MatchListResult] = []
        for item in array
        {
            models.append(MatchListResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {

        code = dictionary["code"] as? String
        message = dictionary["message"] as? String
        meaning = dictionary["meaning"] as? String
    }
}


public class Match_list {
    public var id : String?
    public var first_user_id : String?
    public var second_user_id : String?
    public var match_status : String?
    public var unique_identifier : String?
    public var created_at : String?
    public var updated_at : String?
    public var get_match_user : UserDataModel?
    public var get_match_user_file : String?


    public class func modelsFromDictionaryArray(array:NSArray) -> [Match_list]
    {
        var models:[Match_list] = []
        for item in array
        {
            models.append(Match_list(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {

        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        first_user_id = (dictionary["first_user_id"] as? NSNumber)?.description ?? (dictionary["first_user_id"] as? String)
        second_user_id = (dictionary["second_user_id"] as? NSNumber)?.description ?? (dictionary["second_user_id"] as? String)
        match_status = dictionary["match_status"] as? String
        unique_identifier = dictionary["unique_identifier"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
        if (dictionary["get_match_user"] != nil) { get_match_user = UserDataModel(dictionary: dictionary["get_match_user"] as? NSDictionary ?? NSDictionary()) }
        get_match_user_file = dictionary["get_match_user_file"] as? String
    }

        
}

