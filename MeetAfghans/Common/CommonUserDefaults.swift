//
//  CommonUserDefaults.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 09/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import Foundation

public enum UserDefaultType : String{
    case userID
    case userNickName
    case authToken
    case userMobile
    case userGender
    case userProfession
    case userPrefGender
    case userHeight
    case userDOB
    case userEducation
    case userMaritalStatus
    case userEmail
    case fcmToken
    case userPhoto
    case userAge
}


class CommonUserDefaults {
    static var accessInstance = CommonUserDefaults()
    
    func isLogin() -> Bool {
        if let token = UserDefaults.standard.object(forKey: UserDefaultType.authToken.rawValue) as? String {
            if token == "" {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func save(_ with: String?, forType : UserDefaultType) {
        UserDefaults.standard.set(with, forKey: forType.rawValue)
    }
    
    func get(forType : UserDefaultType) -> String? {
        return UserDefaults.standard.object(forKey: forType.rawValue) as? String
    }
    
    func hasAllUserData()->Bool{
        let arr : [UserDefaultType] = [.userNickName,.userGender,.userDOB,.userProfession,.userEducation,.userMaritalStatus,.userHeight,.userPrefGender]
        var hasData = true
        arr.forEach { (it) in
            if UserDefaults.standard.object(forKey: it.rawValue) as? String ?? "" == ""{
                hasData = false
                return
            }
        }
        return hasData
    }
    
    func removeAll() {
        CommonUserDefaults.accessInstance.save(nil, forType: .userID)
        CommonUserDefaults.accessInstance.save(nil, forType: .userNickName)
        CommonUserDefaults.accessInstance.save(nil, forType: .authToken)
        CommonUserDefaults.accessInstance.save(nil, forType: .userMobile)
        CommonUserDefaults.accessInstance.save(nil, forType: .userGender)
        CommonUserDefaults.accessInstance.save(nil, forType: .userProfession)
        CommonUserDefaults.accessInstance.save(nil, forType: .userPrefGender)
        CommonUserDefaults.accessInstance.save(nil, forType: .userHeight)
        CommonUserDefaults.accessInstance.save(nil, forType: .userDOB)
        CommonUserDefaults.accessInstance.save(nil, forType: .userEducation)
        CommonUserDefaults.accessInstance.save(nil, forType: .userMaritalStatus)
        CommonUserDefaults.accessInstance.save(nil, forType: .userEmail)
    }
    
}
