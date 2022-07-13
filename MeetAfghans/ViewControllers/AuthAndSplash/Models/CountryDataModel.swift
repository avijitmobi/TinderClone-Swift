//
//  RegisterDataModel.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 19/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation

public class CountryDataModel {
    public var jsonrpc : String?
    public var result : CountryDataResult?
    
   
    public class func modelsFromDictionaryArray(array:NSArray) -> [CountryDataModel]
    {
        var models:[CountryDataModel] = []
        for item in array
        {
            models.append(CountryDataModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        jsonrpc = dictionary["jsonrpc"] as? String
        if (dictionary["result"] != nil) { result = CountryDataResult(dictionary: dictionary["result"] as? NSDictionary ?? NSDictionary()) }
    }
    
}


public class CountryDataResult {
    public var country : Array<Countries>?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [CountryDataResult]
    {
        var models:[CountryDataResult] = []
        for item in array
        {
            models.append(CountryDataResult(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        if (dictionary["country"] != nil) { country = Countries.modelsFromDictionaryArray(array: dictionary["country"] as? NSArray ?? NSArray()) }
    }
}


public class Countries {
    public var id : String?
    public var sortname : String?
    public var name : String?
    public var phonecode : String?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Countries]
    {
        var models:[Countries] = []
        for item in array
        {
            models.append(Countries(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        if let id = dictionary["id"] as? NSNumber{
            self.id = id.description
        }else if let id = dictionary["id"] as? String{
            self.id = id
        }
        sortname = dictionary["sortname"] as? String
        name = dictionary["name"] as? String
        if let phonecode = dictionary["phonecode"] as? NSNumber{
            self.phonecode = phonecode.description
        }else if let phonecode = dictionary["phonecode"] as? String{
            self.phonecode = phonecode
        }
    }
    
}
