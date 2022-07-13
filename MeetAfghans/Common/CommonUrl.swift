//
//  CommonUrl.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 09/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation


var platform = "I"

var isLive:Bool = false

public var baseUrl:String{
    get {
        return isLive ? "" : ""
    }
}
public var apiPath:String{
    get {
        return "\(baseUrl)api/"
    }
}

public var googleClientId : String{
    get {
        return ""
    }
}

class CommonUrl : NSObject{
    
    //Image Path
    static let profileImageURL = "\(baseUrl)public/storage/app/user_file/"
    static let adsImageURL = "\(baseUrl)public/storage/app/my_ads"
    static let Platform = "I"
    
    static let terms_conditions = "https://demos.co.uk/terms-conditions/"
    static let privacy_policy = "https://demos.co.uk/privacy-policy/"
    
    static let countryList = apiPath + "select-country"
    
    //Authentication
    static let logout = apiPath + "logout"
    static let email_login = apiPath + "email-login"
    static let phone_login = apiPath + "mobile-login"
    static let signUp = apiPath + "register"
    static let verify_email = apiPath + "email-verification"
    static let verify_phone = apiPath + "otp-verification"
    static let resend_email = apiPath + "resend-email-verification"
    static let resend_phone = apiPath + "resend-otp"
    static let forgot_password = apiPath + "forgot-pass-user"
    static let update_password = apiPath + "update-pass-user"
    static let facebook_login = apiPath + "facebook-login"
    static let appleLogin = apiPath + "apple-login"
    static let google_login = apiPath + "google-login"
    static let edit_profile = apiPath + "edit-profile"
    static let upload_file_image = apiPath + "profile-file"
    static let upload_profile_images = apiPath + "profile-image"
    static let user_block_list = apiPath + "user-block-list"
    static let user_dislike_list = apiPath + "user-dislike-list"
    static let user_like_list = apiPath + "user-like-list"
    static let get_all_user_list = apiPath + "user-list"
    static let get_profile_details = apiPath + "profile-details"
    static let add_ads = apiPath + "my-ads"
    static let edit_ads = apiPath + "my-ads-edit"
    static let ads_list = apiPath + "my-ads-list"
    static let all_ads_list = apiPath + "all-ads"
    static let get_chat_list = "chat-list"
    static let send_chat = "chat"
    static let remove_profile_picture = apiPath + "remove-file"
    static let swap_user = apiPath + "swap"
    static let user_deactivate = apiPath + "user-deactive"
    static let user_delete = apiPath + "user-delete"
    static let get_country_list = apiPath + "country-list"
    static let user_match_list = apiPath + "user-match-list"
    static let access_token_chat = "https://jet-kingfisher-5359.twil.io/chat-token"
    static let access_token_voice = "https://justafgan-4175.twil.io/generate-token"
    static let access_token_video = "https://justafgan-4175.twil.io/video-token"
}
