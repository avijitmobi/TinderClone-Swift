//
//  EMReqeustManager.swift
//  AlmoFire API Calling Example
//
//  Created by Hasya.Panchasara on 03/11/17.
//  Copyright © 2017 Hasya Panchasara. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

typealias requestCompletionHandler = (APIJSONReponse) -> Void

class APIReqeustManager: NSObject {
    
    static let sharedInstance = APIReqeustManager()
    fileprivate override init() {
        super.init()
    }
    public static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            baseUrl : .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let man = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()
    
    fileprivate func sendRequestWithURL(_ URL: String,
                                        method: HTTPMethod,loadingButton : TransitionButton?,needViewHideShowAfterLoading : UIView?,
                                        queryParameters: [String: String]?,
                                        bodyParameters: [String: AnyObject]?,
                                        headers: [String: String]?,
                                        retryCount: Int = 0,
                                        vc : UIViewController,
                                        needsLogin: Bool = false,
                                        completionHandler:@escaping requestCompletionHandler) {
        // If there's a querystring, append it to the URL.
        
        if (Reachablity.sharedInstance.isInternetReachable == false) {
            vc.view.hideAllToasts()
            if loadingButton != nil{
                loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                    needViewHideShowAfterLoading?.isHidden = false
                    let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey as NSObject :  CommonMessages.noInternet as AnyObject,
                            NSLocalizedFailureReasonErrorKey as NSObject : CommonMessages.noInternet as AnyObject
                    ]
                    let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: -1, userInfo: userInfo as? [String : Any])
                    let wrappedResponse = APIJSONReponse.init(error: error, dataDict: [:])
                    completionHandler(wrappedResponse)
                    print(error)
                    return
                })
            }else{
                let userInfo: [NSObject : AnyObject] =
                    [
                        NSLocalizedDescriptionKey as NSObject :  CommonMessages.noInternet as AnyObject,
                        NSLocalizedFailureReasonErrorKey as NSObject : CommonMessages.noInternet as AnyObject
                ]
                let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: -1, userInfo: userInfo as? [String : Any])
                let wrappedResponse = APIJSONReponse.init(error: error, dataDict: [:])
                completionHandler(wrappedResponse)
                print(error)
                return
            }
        }
        
        let actualURL: String
        if let queryParameters = queryParameters {
            var components = URLComponents(string:URL)!
            components.queryItems = queryParameters.map { (key, value) in URLQueryItem(name: key, value: value) }
            actualURL = components.url!.absoluteString
        } else {
            actualURL = URL
        }
        
        var headerParams = [String: String]()
        if let headers = headers {
            headerParams = headers
        }
        print(headerParams)
        print("Actual URL \(actualURL)")
        
        Alamofire.request(actualURL, method:method, parameters: bodyParameters,encoding: JSONEncoding.default, headers: headerParams)
            .responseJSON { response in
                print(response.result)   // result of response serialization
                
                switch response.result {
                case .success:
                    
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        print("JSON: \(JSON)")
                        
                        let wrappedResponse = APIJSONReponse.init(
                            data: response.data,
                            dict: response.result.value as! Dictionary<String, AnyObject>?,
                            response: response.response,
                            error: nil)
                        
                        DispatchQueue.main.async(execute: {
                            completionHandler(wrappedResponse)
                        })
                    }
                    
                case .failure(let error):
                    let error = error
                    let wrappedResponse = APIJSONReponse.init(error: error, dataDict: [:])
                    completionHandler(wrappedResponse)
                    print(error.localizedDescription)
                }
        }
    }
}

extension APIReqeustManager {
    
    func serviceCall(param:[String:Any]?,
                     queryParam : [String:String]? = nil,
                     method : HTTPMethod,
                     loaderNeed : Bool,
                     loaderPosition : ToastPosition = .center,
                     loadingButton : TransitionButton?,
                     successMessageParams: String? = nil,
                     errorMessageParams: String? = nil,
                     needPopWhenErrorAlertCome : Bool = false,
                     needViewHideShowAfterLoading : UIView?,
                     userInteractionCheck : Bool = false,
                     vc:UIViewController,url: String,
                     isTokenNeeded : Bool,
                     header : [String : String]? = nil,
                     isErrorAlertNeeded : Bool,
                     isSuccessAlertNeeded : Bool,
                     errorBlock:(()->())? = nil,
                     actionErrorOrSuccess:((Bool,String) -> ())?,
                     noInternetOrErrorCallBack:(() -> ())? = nil,
                     fromLoginPageCallBack:(() -> ())?,
                     completionHandler:@escaping requestCompletionHandler) {
        if loadingButton != nil{
            loadingButton?.startAnimation()
        }
//        if isTokenNeeded{
//            if !CommonUserDefaults.accessInstance.isLogin(){
//                vc.checkAndProcessToLogin(from: vc) {
//                    fromLoginPageCallBack?()
//                }
//                return
//            }
//        }
        if loaderNeed{
            if #available(iOS 13.0, *) {
                vc.view.makeToastActivity(loaderPosition)
            } else {
                vc.view.makeToastActivity(vc.view.center)
            }
        }
        if userInteractionCheck{
            vc.view.isUserInteractionEnabled = false
            vc.navigationController?.navigationBar.isUserInteractionEnabled = false
            vc.navigationController?.view.isUserInteractionEnabled = false
        }else{
            vc.navigationController?.navigationBar.isUserInteractionEnabled = true
            vc.navigationController?.view.isUserInteractionEnabled = true
            vc.view.isUserInteractionEnabled = true
        }
        needViewHideShowAfterLoading?.isHidden = true
        let params  = ["jsonrpc" : "2.0", "params" : param ?? nil] as [String : Any?]
        print(params)
        sendRequestWithURL(url, method: method, loadingButton: loadingButton, needViewHideShowAfterLoading: needViewHideShowAfterLoading, queryParameters: queryParam, bodyParameters: (param != nil) ? (params as [String : AnyObject]?) : nil, headers: isTokenNeeded ? ["Authorization" : "Bearer \(CommonUserDefaults.accessInstance.get(forType: .authToken) ?? "")"] : nil, vc: vc){
            resp in
            vc.view.hideAllToasts(includeActivity: true, clearQueue: true)
            if resp.error != nil{
                if vc.presentedViewController == nil{
                    vc.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.ok, message: resp.error?.localizedDescription ?? CommonMessages.somethingWentWrong) {
                        if needPopWhenErrorAlertCome {
                            if let nav = vc.navigationController{
                                nav.popToRootViewController(animated: true)
                            }
                        }
                    }
                }else{
                    vc.view.makeToast(resp.error?.localizedDescription,duration : 4)
                }
                vc.navigationController?.navigationBar.isUserInteractionEnabled = true
                vc.navigationController?.view.isUserInteractionEnabled = true
                vc.view.isUserInteractionEnabled = true
                noInternetOrErrorCallBack?()
                if loadingButton != nil{
                    loadingButton?.stopAnimation()
                }
                return
            }
            if resp.HTTPResponse?.statusCode == 401{
                if loadingButton != nil{
                    loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                        needViewHideShowAfterLoading?.isHidden = false
                        vc.showSingleButtonAlertWithAction(title: CommonMessages.authFailed, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.tokenExpire) {
                            CommonUserDefaults.accessInstance.removeAll()
                            vc.checkAndProcessToLogin(from: vc) {
                                fromLoginPageCallBack?()
                            }
                        }
                        return
                    })
                }else{
                    vc.showSingleButtonAlertWithAction(title: CommonMessages.authFailed, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.tokenExpire) {
                        CommonUserDefaults.accessInstance.removeAll()
                        vc.checkAndProcessToLogin(from: vc) {
                            fromLoginPageCallBack?()
                        }
                    }
                    return
                }
                loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                    
                })
                return
            }else if let err = resp.dict?["error"] as? String, err == "user_not_found"{
                vc.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.inactiveState) {
                    let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
                    CommonUserDefaults.accessInstance.removeAll()
                    Helper.replaceRootView(for: mainNav, animated: true)
                }
                return
            }else if let err = ((resp.dict?["error"] as? [String : Any])?["status"] as? [String : Any] ?? (resp.dict?["error"] as? [String : Any])){
                if err["code"] as? String == "-33085" {
                    vc.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.continueWithLogin, message: err["meaning"] as? String ?? CommonMessages.inactiveState) {
                        CommonUserDefaults.accessInstance.removeAll()
                        vc.checkAndProcessToLogin(from: vc) {
                            fromLoginPageCallBack?()
                        }
                    }
                    return
                }else{
                    if loadingButton != nil{
                        loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                            needViewHideShowAfterLoading?.isHidden = false
                            let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: (Int(err["code"] as? String ?? "-1") ?? -1), userInfo: err)
                            let wrappedResponse = APIJSONReponse(data: resp.data, dict: resp.dict, response: resp.response, error: error)
                            completionHandler(wrappedResponse)
                            errorBlock?()
                            if isErrorAlertNeeded{
                                vc.showSingleButtonAlertWithAction(title: err["message"] as? String ?? CommonMessages.error, buttonTitle: CommonMessages.ok, message: err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong) {
                                    actionErrorOrSuccess?(false, err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                }
                            }
                        })
                    }else{
                        let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: (Int(err["code"] as? String ?? "-1") ?? -1), userInfo: err)
                        let wrappedResponse = APIJSONReponse(data: resp.data, dict: resp.dict, response: resp.response, error: error)
                        completionHandler(wrappedResponse)
                        errorBlock?()
                        if isErrorAlertNeeded{
                            vc.showSingleButtonAlertWithAction(title: err["message"] as? String ?? CommonMessages.error, buttonTitle: CommonMessages.ok, message: err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong) {
                                actionErrorOrSuccess?(false, err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                            }
                        }
                    }
                }
                
            }else if let res =  ((resp.dict?["result"] as? [String : Any])?["status"] as? [String : Any] ?? (resp.dict?["result"] as? [String : Any])){
                if loadingButton != nil{
                    loadingButton?.stopAnimation(animationStyle: .normal, completion: {
                        needViewHideShowAfterLoading?.isHidden = false
                        completionHandler(resp)
                        if let msg = res["message"] as? String{
                            if isSuccessAlertNeeded{
                                vc.showSingleButtonAlertWithAction(title: msg, buttonTitle: CommonMessages.ok, message: res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.alert) {
                                    actionErrorOrSuccess?(true, res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                }
                            }
                        }
                    })
                }else{
                    completionHandler(resp)
                    if let msg = res["message"] as? String{
                        if isSuccessAlertNeeded{
                            vc.showSingleButtonAlertWithAction(title: msg, buttonTitle: CommonMessages.ok, message: res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.alert) {
                                actionErrorOrSuccess?(true, res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                            }
                        }
                    }
                }
            }else if resp.error != nil{
                if loadingButton != nil{
                    loadingButton?.stopAnimation(animationStyle: .shake, completion: {
                        needViewHideShowAfterLoading?.isHidden = false
                        completionHandler(resp)
                        vc.view.makeToast(resp.error?.localizedDescription ?? CommonMessages.somethingWentWrong)
                    })
                }else{
                    completionHandler(resp)
                    vc.view.makeToast(resp.error?.localizedDescription ?? CommonMessages.somethingWentWrong)
                }
                
            }else{
                if loadingButton != nil{
                    loadingButton?.stopAnimation(animationStyle: .normal, completion: {
                        needViewHideShowAfterLoading?.isHidden = false
                        completionHandler(resp)
                    })
                }else{
                    completionHandler(resp)
                }
            }
            vc.navigationController?.navigationBar.isUserInteractionEnabled = true
            vc.navigationController?.view.isUserInteractionEnabled = true
            vc.view.isUserInteractionEnabled = true
            needViewHideShowAfterLoading?.isHidden = false
        }
    }
    
    func uploadWithAlamofire(multipart : @escaping (MultipartFormData) -> (),
                             url : String,
                             method : HTTPMethod,
                             loadingButton : TransitionButton?,
                             loaderNeed : Bool,
                             loaderPosition : ToastPosition = .center,
                             needViewHideShowAfterLoading : UIView?,
                             successMessageParams: String? = nil,
                             errorMessageParams: String? = nil,
                             userInteractionCheck : Bool = true,vc:UIViewController,
                             isTokenNeeded : Bool,
                             progressValue: @escaping (Double) -> (),
                             isErrorAlertNeeded : Bool,
                             isSuccessAlertNeeded : Bool = false,
                             errorBlock:(()->())? = nil,
                             actionErrorOrSuccess:((Bool,String) -> ())?,
                             fromLoginPageCallBack:(() -> ())?,
                             responseDict : @escaping (NSDictionary?,NSError?) -> ()){
        
        if loadingButton != nil{
            needViewHideShowAfterLoading?.isHidden = true
            loadingButton?.startAnimation()
        }
        if isTokenNeeded{
            if !CommonUserDefaults.accessInstance.isLogin(){
                return
            }
        }
        if loaderNeed{
            if #available(iOS 13.0, *) {
                vc.view.makeToastActivity(loaderPosition)
            } else {
                vc.view.makeToastActivity(vc.view.center)
            }
        }
        if userInteractionCheck{
            vc.view.isUserInteractionEnabled = false
            vc.navigationController?.navigationBar.isUserInteractionEnabled = false
            vc.navigationController?.view.isUserInteractionEnabled = false
        }else{
            vc.navigationController?.navigationBar.isUserInteractionEnabled = true
            vc.navigationController?.view.isUserInteractionEnabled = true
            vc.view.isUserInteractionEnabled = true
        }
        print("Url :   ------   \(url)")
        Alamofire.upload(multipartFormData: multipart, to: url, method: method, headers: isTokenNeeded ? ["Authorization" : "Bearer \(CommonUserDefaults.accessInstance.get(forType: .authToken) ?? "")"] : nil) { (result) in
            vc.view.hideToastActivity()
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress (closure: { (progress) in
                    progressValue(Double(round(progress.fractionCompleted * 100)/100))
                })
                upload.responseString { response in
                    vc.navigationController?.navigationBar.isUserInteractionEnabled = true
                    vc.navigationController?.view.isUserInteractionEnabled = true
                    vc.view.isUserInteractionEnabled = true
                    if response.response?.statusCode == 401{
                        if loadingButton != nil{
                            loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                                needViewHideShowAfterLoading?.isHidden = false
                                vc.showSingleButtonAlertWithAction(title: CommonMessages.authFailed, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.tokenExpire) {
                                    CommonUserDefaults.accessInstance.removeAll()
                                    vc.checkAndProcessToLogin(from: vc) {
                                        fromLoginPageCallBack?()
                                    }
                                }
                                return
                            })
                        }else{
                            vc.showSingleButtonAlertWithAction(title: CommonMessages.authFailed, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.tokenExpire) {
                                CommonUserDefaults.accessInstance.removeAll()
                                vc.checkAndProcessToLogin(from: vc) {
                                    fromLoginPageCallBack?()
                                }
                            }
                            return
                        }
                    }
                    debugPrint("Debug:::\(response.result.value ?? "")")
                    do {
                        if let resp = response.result.value{
                            if let data = resp.data(using: .utf8) {
                                do {
                                    let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                    if let err = dict?["error"] as? String, err == "user_not_found"{
                                        vc.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.continueWithLogin, message: CommonMessages.inactiveState) {
                                            let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
                                            CommonUserDefaults.accessInstance.removeAll()
                                            Helper.replaceRootView(for: mainNav, animated: true)
                                        }
                                        return
                                    }else if let err =  ((dict?["error"] as? [String : Any])?["status"] as? [String : Any] ?? (dict?["error"] as? [String : Any])){
                                        if err["code"] as? String == "-33085"{
                                            vc.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.continueWithLogin, message: err["meaning"] as? String ?? CommonMessages.inactiveState) {
                                                CommonUserDefaults.accessInstance.removeAll()
                                                vc.checkAndProcessToLogin(from: vc) {
                                                    fromLoginPageCallBack?()
                                                }
                                            }
                                            return
                                        }else{
                                            if loadingButton != nil{
                                                loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                                                    needViewHideShowAfterLoading?.isHidden = false
                                                    let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: (Int(err["code"] as? String ?? "-1") ?? -1), userInfo: err)
                                                    responseDict(nil, error)
                                                    errorBlock?()
                                                    if isErrorAlertNeeded{
                                                        vc.showSingleButtonAlertWithAction(title: err["message"] as? String ?? CommonMessages.error, buttonTitle: CommonMessages.ok, message: err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong) {
                                                            actionErrorOrSuccess?(false, err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                                        }
                                                    }
                                                })
                                            }else{
                                                let error : NSError = NSError(domain: "EnomjiHttpResponseErrorDomain", code: (Int(err["code"] as? String ?? "-1") ?? -1), userInfo: err)
                                                responseDict(nil, error)
                                                errorBlock?()
                                                if isErrorAlertNeeded{
                                                    vc.showSingleButtonAlertWithAction(title: err["message"] as? String ?? CommonMessages.error, buttonTitle: CommonMessages.ok, message: err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong) {
                                                        actionErrorOrSuccess?(false, err[errorMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }else if let res =  ((dict?["result"] as? [String : Any])?["status"] as? [String : Any] ?? (dict?["result"] as? [String : Any])){
                                        if loadingButton != nil{
                                            loadingButton?.stopAnimation(animationStyle: .normal, revertAfterDelay: 1, completion: {
                                                needViewHideShowAfterLoading?.isHidden = false
                                                responseDict(dict as NSDictionary?, nil)
                                                if let msg = res["message"] as? String{
                                                    if isSuccessAlertNeeded{
                                                        vc.showSingleButtonAlertWithAction(title: msg, buttonTitle: CommonMessages.ok, message: res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.alert) {
                                                            actionErrorOrSuccess?(true,res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                                        }
                                                    }
                                                    
                                                }
                                            })
                                        }else{
                                            responseDict(dict as NSDictionary?, nil)
                                            if let msg = res["message"] as? String{
                                                if isSuccessAlertNeeded{
                                                    vc.showSingleButtonAlertWithAction(title: msg, buttonTitle: CommonMessages.ok, message: res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.alert) {
                                                        actionErrorOrSuccess?(true,res[successMessageParams ?? "meaning"] as? String ?? CommonMessages.somethingWentWrong)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }else{
                                        if loadingButton != nil{
                                            loadingButton?.stopAnimation(animationStyle: .normal, revertAfterDelay: 1, completion: {
                                                needViewHideShowAfterLoading?.isHidden = false
                                                responseDict(dict as NSDictionary?, nil)
                                            })
                                        }else{
                                            responseDict(dict as NSDictionary?, nil)
                                        }
                                        
                                    }
                                    
                                } catch {
                                    if loadingButton != nil{
                                        loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                                            needViewHideShowAfterLoading?.isHidden = false
                                            vc.view.makeToast(error.localizedDescription)
                                        })
                                    }else{
                                        vc.view.makeToast(error.localizedDescription)
                                    }
                                    errorBlock?()
                                }
                            }
                        }else{
                            errorBlock?()
                            debugPrint("response:::",response.result.debugDescription)
                        }
                    }
                }
            case .failure(let encodingError):
                vc.navigationController?.navigationBar.isUserInteractionEnabled = true
                vc.navigationController?.view.isUserInteractionEnabled = true
                vc.view.isUserInteractionEnabled = true
                if loadingButton != nil{
                    loadingButton?.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                        needViewHideShowAfterLoading?.isHidden = false
                        vc.view.makeToast(encodingError.localizedDescription)
                    })
                }else{
                    vc.view.makeToast(encodingError.localizedDescription)
                }
                errorBlock?()
                debugPrint(encodingError.localizedDescription)
                break
            }
        }
    }
}
