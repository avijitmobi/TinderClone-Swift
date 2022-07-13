//
//  AuthUserData.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 05/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import Foundation

public class AuthUserDataModel {
    public var jsonrpc : String?
    public var result : AuthUserResult?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [AuthUserDataModel]
    {
        var models:[AuthUserDataModel] = []
        for item in array
        {
            models.append(AuthUserDataModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["result"] != nil) { result = AuthUserResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}


public class AuthUserResult {
    public var userdata : UserDataModel?
    public var token : String?
    public var age : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [AuthUserResult]
    {
        var models:[AuthUserResult] = []
        for item in array
        {
            models.append(AuthUserResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        if (dictionary["userdata"] != nil) { userdata = UserDataModel(dictionary: dictionary["userdata"] as? NSDictionary ?? NSDictionary()) }
        token = dictionary["token"] as? String
        age = (dictionary["age"] as? NSNumber)?.description ?? (dictionary["age"] as? String)
    }
    
}


public class UserDataModel {
    public var id : String?
    public var name : String?
    public var nick_name : String?
    public var lname : String?
    public var email : String?
    public var email_verified_at : String?
    public var password : String?
    public var remember_token : String?
    public var created_at : String?
    public var updated_at : String?
    public var user_type : String?
    public var user_status : String?
    public var email_vcode : String?
    public var image : String?
    public var mobile : String?
    public var is_verified : String?
    public var dob : String?
    public var about : String?
    public var gender : String?
    public var living : String?
    public var enhnic_group : String?
    public var level_of_education : String?
    public var marital_status : String?
    public var height : String?
    public var find_gender : String?
    public var facebook_id : String?
    public var google_id : String?
    public var is_global : String?
    public var min_km : String?
    public var max_km : String?
    public var passion : String?
    public var job_title : String?
    public var company : String?
    public var college_school : String?
    public var city : String?
    public var show_my_age : String?
    public var my_distance_visible : String?
    public var age : String?
    public var distance : String?
    public var get_user_file : Array<UserImageModel>?
    public var get_match_user_file : Array<UserImageModel>?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [UserDataModel]
    {
        var models:[UserDataModel] = []
        for item in array
        {
            models.append(UserDataModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        age = (dictionary["age"] as? NSNumber)?.description ?? (dictionary["age"] as? String)
        distance = (dictionary["distance"] as? NSNumber)?.description ?? (dictionary["distance"] as? String)
        id = (dictionary["id"] as? NSNumber)?.description ?? (dictionary["id"] as? String)
        name = dictionary["name"] as? String
        nick_name = dictionary["nick_name"] as? String
        lname = dictionary["lname"] as? String
        email = dictionary["email"] as? String
        email_verified_at = dictionary["email_verified_at"] as? String
        password = dictionary["password"] as? String
        remember_token = dictionary["remember_token"] as? String
        created_at = dictionary["created_at"] as? String
        updated_at = dictionary["updated_at"] as? String
        user_type = dictionary["user_type"] as? String
        user_status = dictionary["user_status"] as? String
        email_vcode = dictionary["email_vcode"] as? String
        image = dictionary["image"] as? String
        mobile = (dictionary["mobile"] as? NSNumber)?.description ?? (dictionary["mobile"] as? String)
        is_verified = dictionary["is_verified"] as? String
        dob = dictionary["dob"] as? String
        about = dictionary["about"] as? String
        gender = dictionary["gender"] as? String
        living = dictionary["living"] as? String
        enhnic_group = dictionary["enhnic_group"] as? String
        level_of_education = dictionary["level_of_education"] as? String
        marital_status = dictionary["marital_status"] as? String
        height = (dictionary["height"] as? NSNumber)?.description ?? (dictionary["height"] as? String)
        find_gender = dictionary["find_gender"] as? String
        facebook_id = dictionary["facebook_id"] as? String
        google_id = dictionary["google_id"] as? String
        is_global = dictionary["is_global"] as? String
        min_km = (dictionary["min_km"] as? NSNumber)?.description ?? (dictionary["min_km"] as? String)
        max_km = (dictionary["max_km"] as? NSNumber)?.description ?? (dictionary["max_km"] as? String)
        passion = dictionary["passion"] as? String
        job_title = dictionary["job_title"] as? String
        company = dictionary["company"] as? String
        college_school = dictionary["college_school"] as? String
        city = dictionary["city"] as? String
        show_my_age = dictionary["show_my_age"] as? String
        my_distance_visible = dictionary["my_distance_visible"] as? String
        if (dictionary["get_user_file"] != nil) { get_user_file = UserImageModel.modelsFromDictionaryArray(array: dictionary["get_user_file"] as? NSArray ?? NSArray()) }
        if (dictionary["get_match_user_file"] != nil) { get_match_user_file = UserImageModel.modelsFromDictionaryArray(array: dictionary["get_match_user_file"] as? NSArray ?? NSArray()) }
    }
}
