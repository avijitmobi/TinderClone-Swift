//
//  EMJSONReponse.swift
//  AlmoFire API Calling Example
//
//  Created by Hasya.Panchasara on 03/11/17.
//  Copyright © 2017 Hasya Panchasara. All rights reserved.
//


import Foundation

struct APIError{
    static let domain = "CVErrorDomain"
    static let networkCode = -1
    static let userInfoKey = "description"
}

class APIJSONReponse {
    let data: Data?
    let dict: Dictionary<String, AnyObject>?
    let response: URLResponse?
    var error: Error?
    var message : String?
    
    init(data: Data?, dict: Dictionary<String, AnyObject>?, response: URLResponse?,error: Error?){
        self.data = data
        self.dict = dict
        self.response = response
        self.error = error
        
        //If not error
        if (self.error == nil) {
            
            if let feedDict = dict {
                
                let baseModel = APIBaseModel.init(jsonDict: feedDict)
                message = baseModel.message
                //If feed retrival is success
                if(baseModel.status != APIResponseStatusKeys.success){
                    if let message  = baseModel.message {
                        if self.HTTPResponse?.statusCode != 200 {
                            self.error = NSError(domain:APIError.domain, code: self.HTTPResponse?.statusCode ?? 450, userInfo:[NSLocalizedDescriptionKey:message])
                        } else {
                            self.error = NSError(domain:APIError.domain, code:7777 , userInfo:[NSLocalizedDescriptionKey:message])
                        }
                    }
                }
                
            }
            
        }
    }
    
    init(error: Error? ,dataDict : NSDictionary ){
        self.data = nil
        self.dict = nil
        self.response = nil
        self.error = error
    }
    
    var HTTPResponse: HTTPURLResponse? {
        return response as? HTTPURLResponse
    }
    
    var responseData: Data? {
        return data as Data?
    }
    
    var responseDict: AnyObject? {
        return dict as AnyObject?
    }
    
    var responseMessage: String? {
        return message 
    }
}
