//
//  CommonMessage.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 09/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation

enum ValidatorType : String{
    
    case email = "Please enter a valid email address"
    case password = "Please enter a valid password"
    case confirmPassword = "Password and confirm password must be same"
    case language = "Please select language"
    case name = "Please enter your name."
    case nickName = "Please enter your nick name."
    case occupation = "Please select your occupation."
    case academic = "Please select your level of education."
    case genderPref = "Please select your gender preference."
    case height = "Please select your height."
    case marital = "Please select your marital status."
    case gender = "Please select your gender."
    case dateOfBirth = "Please select your date of birth."
    case country = "Please select country from list"
    case mobileNo = "Please enter a valid mobile no."
    case address = "Please type your full address."
    case state = "Please enter your state name."
    case city = "Please enter your city name."
    case about = "Please enter your about."
    case passion = "Please enter your passion."
    case job_title = "Please enter your job title."
    case company = "Please enter your company name."
    case college_school = "Please enter your school and college name."
    case zip = "Please enter your zip code."
    case otp = "Please enter a valid one time password."
    case country_code = "Please choose your country code."
    
    case business_name = "Please enter your business name."
    case packange_price = "Please choose your preferable package."
    case package_duration = "Please choose your preferable package duration."
    case ads_url = "Please enter your website or brand url."
    case ads_description = "Please enter your ads descriptions."
    case ads_photo = "Please enter your website or brand photo or video."
    
}

class CommonMessages{
    static let tokenExpire = "Your session has expired. Try to relogging your account."
    static let success = "Successful"
    static let error = "Error"
    static let registerSuccess = "You have been registered successfully"
    static let ok = "Okay"
    static let alert = "Alert"
    static let authFailed = "Authentication Failed"
    static let continueWithLogin = "Continue with login"
    static let inactiveState = "Your account has been deleted from our database or currently in inactive state."
    static let logout = "You are logged out from the app. Please re-login"
    static let taskSuccessful = "Your current task successful."
    static let accountInactiveState = "Your account is currently in inactive or unverified state."
    static let noInternet = "No Internet Connection is there."
    static let somethingWentWrong = "Something Went Wrong \n Please Try After Some Time"
    static let locationPermissionTitle = "Location Permission Reject"
    static let locationPermissionMessage = "Please allow location permission, otherwise we can not proper match. Please approve it from settings"
    static let cancel = "Cancel"
    static let openSettings = "Open Settings"
    static func validationError(of type : ValidatorType) -> String{
        return type.rawValue
    }
    
}


class CommonString {
    
    static let dobFormat = "yyyy-MM-dd"
    
}
