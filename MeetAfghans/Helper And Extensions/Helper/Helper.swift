//
//  Helper.swift
//  Zomato Clone App
//
//  Created by Convergent Infoware on 19/12/19.
//  Copyright © 2019 Convergent Infoware. All rights reserved.
//

import Foundation
import UIKit

func getVcObject(vcName:VCNameCase, StoryBoardName:StoryBoardNameCase) -> UIViewController{
    
    let storyBoard: UIStoryboard = UIStoryboard(name: StoryBoardName.rawValue, bundle: nil)
    let vc = storyBoard.instantiateViewController(withIdentifier: vcName.rawValue)
    
    return vc
}


enum StoryBoardNameCase: String {
    case Main = "Main"
    case Auth = "Auth"
    case Profile = "Profile"
    case Chat = "Chat"
}

enum VCNameCase: String {
    
    //Navigation
    case AuthNavigationController = "AuthNavigationController"
    case MainNavigationController = "MainNavigationController"
    case ProfileNavigationController = "ProfileNavigationController"
    
    // Before Login
    case SplashVideoVC = "SplashVideoVC"
    case SplashScreenVC = "SplashScreenVC"
    case LoginVC = "LoginVC"
    case LoginRegisterVC  = "LoginRegisterVC"
    case RegisterVC = "RegisterVC"
    case LoginMobileVC = "LoginMobileVC"
    case LoginEmailVC = "LoginEmailVC"
    case SignUpEmailVC = "SignUpEmailVC"
    case SignUpPhoneVC = "SignUpPhoneVC"
    case OTPVerificationVC = "OTPVerificationVC"
    case ForgotPasswordVC = "ForgotPasswordVC"
    
    
    //Main VCs
    case SwipeCardsVC = "SwipeCardsVC"
    case SwipeCardsDetailsVC = "SwipeCardsDetailsVC"
    
    //Profiles
    case ProfileVC = "ProfileVC"
    case ProfileNickNameVC = "ProfileNickNameVC"
    case ProfileGenderVC = "ProfileGenderVC"
    case ProfileOccupationVC = "ProfileOccupationVC"
    case ProfileDOBVC = "ProfileDOBVC"
    case ProfileEthnicVC = "ProfileEthnicVC"
    case ProfilePartnerGenderVC = "ProfilePartnerGenderVC"
    case ProfileHeightVC = "ProfileHeightVC"
    case ProfileMaritalStatusVC = "ProfileMaritalStatusVC"
    case ProfileAcademicVC = "ProfileAcademicVC"
    case ProfilePhotoMediaVC = "ProfilePhotoMediaVC"
    case CurrentSubscriptionVC = "CurrentSubscriptionVC"
    case AddEditAdsVC = "AddEditAdsVC"
    
    //Ads
    case AdsVC = "AdsVC"
    
    //Chats
    case ChatListVC = "ChatListVC"
    case ChatDetailsVC = "ChatDetailsVC"
    case UserListVC = "UserListVC"
    case AudioVideoCallVC = "AudioVideoCallVC"
    
}


//MARK: - Helper Class Is Here-

class Helper {
    
    static func getVcObject(vcName:VCNameCase, StoryBoardName:StoryBoardNameCase) -> UIViewController{
        
        let storyBoard: UIStoryboard = UIStoryboard(name: StoryBoardName.rawValue, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vcName.rawValue)
        
        return vc
    }
    
    
    static func replaceRootView(for rootViewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated {
            UIView.transition(with: keyWindow ?? UIWindow(), duration: 0.5, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                keyWindow?.rootViewController = rootViewController
                keyWindow?.makeKeyAndVisible()
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                completion?()
            })
        } else {
            keyWindow?.rootViewController = rootViewController
            keyWindow?.makeKeyAndVisible()
        }
    }
    
}

