//
//  SplashVideoVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 04/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit
import AVFoundation
//import GoogleSignIn
import FacebookLogin
import FacebookCore

class SplashVideoVC: UIViewController,PopoverViewDelegate {
    
    @IBOutlet weak var coloredView : UIView!
    @IBOutlet weak var containerView : UIView!
    
    var player: AVPlayer?
    
    let loginRegisterVC = Helper.getVcObject(vcName: .LoginRegisterVC, StoryBoardName: .Auth) as! LoginRegisterVC
    let loginPhoneVC = Helper.getVcObject(vcName: .LoginMobileVC, StoryBoardName: .Auth) as! LoginMobileVC
    let loginEmailVC = Helper.getVcObject(vcName: .LoginEmailVC, StoryBoardName: .Auth) as! LoginEmailVC
    let signUpPhoneVC = Helper.getVcObject(vcName: .SignUpPhoneVC, StoryBoardName: .Auth) as! SignUpPhoneVC
    let signUpEmailVC = Helper.getVcObject(vcName: .SignUpEmailVC, StoryBoardName: .Auth) as! SignUpEmailVC
    let otpVC = Helper.getVcObject(vcName: .OTPVerificationVC, StoryBoardName: .Auth) as! OTPVerificationVC
    let registerVC = Helper.getVcObject(vcName: .RegisterVC, StoryBoardName: .Auth) as! RegisterVC
    let forgotPasswordVC = Helper.getVcObject(vcName: .ForgotPasswordVC, StoryBoardName: .Auth) as! ForgotPasswordVC
    let loginVC = Helper.getVcObject(vcName: .LoginVC, StoryBoardName: .Auth) as! LoginVC
    var lastVCs = [UIViewController?]()
    
    private var isLogin : Bool = false
    private var email : String? = "avijitmobi@gmail.com"
    private var emailPassword : String? = "12345678"
    private var phone : String?
    private var phonePassword : String?
    private var userDataDB = AuthUserDataModel(dictionary: NSDictionary()){
        didSet{
            if userDataDB?.result?.userdata?.user_status != "A" {
                self.showSingleButtonAlertWithAction(title: "Not Active", buttonTitle: "Okay", message: "Your account has been deactivated. Please reachout with us to re-activate your account.") {
                    
                }
            }else if let token = userDataDB?.result?.token{
                let user = userDataDB?.result?.userdata
                CommonUserDefaults.accessInstance.save(token, forType: .authToken)
                CommonUserDefaults.accessInstance.save(user?.id?.description, forType: .userID)
                CommonUserDefaults.accessInstance.save(user?.email, forType: .userEmail)
                CommonUserDefaults.accessInstance.save(user?.mobile, forType: .userMobile)
                CommonUserDefaults.accessInstance.save(user?.gender, forType: .userGender)
                CommonUserDefaults.accessInstance.save(user?.dob, forType: .userDOB)
                CommonUserDefaults.accessInstance.save(user?.height, forType: .userHeight)
                CommonUserDefaults.accessInstance.save(user?.level_of_education, forType: .userEducation)
                CommonUserDefaults.accessInstance.save(user?.living, forType: .userProfession)
                CommonUserDefaults.accessInstance.save(user?.nick_name, forType: .userNickName)
                CommonUserDefaults.accessInstance.save(user?.marital_status, forType: .userMaritalStatus)
                CommonUserDefaults.accessInstance.save(user?.find_gender, forType: .userPrefGender)
                CommonUserDefaults.accessInstance.save(userDataDB?.result?.age, forType: .userAge)
                CommonUserDefaults.accessInstance.save(user?.get_user_file?.filter({($0.file_name ?? "" != "") && (($0.file_name?.contains(".jpg") ?? false) || ($0.file_name?.contains(".png") ?? false))}).first?.file_name, forType: .userPhoto)
                goToHome()
            }
        }
    }
    private var activeCountryDropdownButton : UIButton?
    private let localeCountryID = Locale.current.regionCode ?? ""
    private var popoverView: PopoverView?
    private var countryData : CountryDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popoverView = PopoverView(parentView: self, delegate: self)
        loginRegisterVC.parentVC = self
        loginPhoneVC.parentVC = self
        loginEmailVC.parentVC = self
        signUpPhoneVC.parentVC = self
        signUpEmailVC.parentVC = self
        registerVC.parentVC = self
        loginVC.parentVC = self
        initializeVideoPlayerWithVideo()
        getCountries()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageContainerCountryDropdownClick()
        manageContaninerButtonClick()
    }
    
    private func manageContainerCountryDropdownClick(){
        loginPhoneVC.countryClickClosure = { [weak self] _ in
            guard let `self` = self else {return}
            if let data = self.countryData?.result?.country,data.count > 0{
                self.popoverView?.show(with: data, sender: self.loginPhoneVC.btnPhoneCodeDropDown, needSearch: true,showDirection: (self.loginPhoneVC.btnPhoneCodeDropDown.frame.y > self.view.center.y) ? .up : .down)
            }
        }
        
        signUpPhoneVC.countryClickClosure = { [weak self] _ in
            guard let `self` = self else {return}
            if let data = self.countryData?.result?.country,data.count > 0{
                self.popoverView?.show(with: data, sender: self.signUpPhoneVC.btnPhoneCodeDropDown, needSearch: true,showDirection: (self.signUpPhoneVC.btnPhoneCodeDropDown.frame.y > self.view.center.y) ? .up : .down)
            }
        }
    }
    
    private func getCountries() {
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.get_country_list, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { [weak self] (resp) in
            self?.countryData = CountryDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
            let data = self?.countryData?.result?.country
            if let foundData = data?.first(where: { $0.sortname == self?.localeCountryID }) {
                self?.activeCountryDropdownButton?.setTitle("+\(foundData.phonecode ?? "91") ▼", for: .normal)
            }
        }
    }
    
    func getvalue(index: Int, indexPath: IndexPath, sender: UIView) {
        if let data = countryData?.result?.country,data.count > 0{
            self.activeCountryDropdownButton?.setTitle("+\(data[index].phonecode ?? "91") ▼", for: .normal)
        }
    }
    
    private func manageContaninerButtonClick(){
        
        loginRegisterVC.buttonClickClosure = { [weak self] clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .register:
                self.removeAndEmbdedLast(withPusing: self.registerVC)
                break
            case .login:
                self.removeAndEmbdedLast(withPusing: self.loginVC)
                break
            case .troubleSignIn:
                self.removeAndEmbdedLast(withPusing: self.forgotPasswordVC)
                break
            }
        }
        
        forgotPasswordVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .back:
                self.removeAndEmbdedLast()
                break
            case .forgotPassword:
//                guard let phone = self.loginPhoneVC.txtPhone.text?.trim(), phone.count >= 8 else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .mobileNo))
//                }
//                guard let password = self.loginPhoneVC.txtPassword.text?.trim(), password.count > 5 else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .password))
//                }
//
//                guard var code = self.loginPhoneVC.btnPhoneCodeDropDown.titleLabel?.text else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
//                }
//                code = code.replacingOccurrences(of: "+", with: "")
//                code = code.replacingOccurrences(of: "▼", with: "").trim()
//
//                guard code != "" else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
//                }
//
//                let param = ["country_code" : code,
//                             "mobile" : phone,
//                             "password" : password]
//                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.phone_login, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
//
//                }, fromLoginPageCallBack: nil) { (resp) in
//                    let data = AuthUserDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
//                    self.userDataDB = data
//                }
                break
            }
        }
        
        registerVC.buttonClickClosure = { [weak self] clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .back:
                self.removeAndEmbdedLast()
                break
            case .signUpWithEmail:
                self.removeAndEmbdedLast(withPusing: self.signUpEmailVC)
                break
            case .signUpWithPhone:
                self.removeAndEmbdedLast(withPusing: self.signUpPhoneVC)
                self.activeCountryDropdownButton = self.signUpPhoneVC.btnPhoneCodeDropDown
                break
            case .signupWithFacebook:
                self.facebookLoginClick()
                break
            case .signupWithGoogle :
                self.googleLoginClick()
                break
            }
        }
        
        loginVC.buttonClickClosure = { [weak self] clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .back:
                self.removeAndEmbdedLast()
                break
            case .signInWithEmail:
                self.removeAndEmbdedLast(withPusing: self.loginEmailVC)
                break
            case .signInWithPhone:
                self.removeAndEmbdedLast(withPusing: self.loginPhoneVC)
                self.activeCountryDropdownButton = self.loginPhoneVC.btnPhoneCodeDropDown
                break
            case .signInWithFacebook:
                self.facebookLoginClick()
                break
            case .signInWithGoogle :
                self.googleLoginClick()
                break
            }
        }
        
        otpVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .verifyNow:
                guard let otp = self.otpVC.txtOTP.text?.trim(), otp.count == 6 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .otp))
                }
                let param = ["email" : self.otpVC.email ?? "",
                             "mobile" : self.otpVC.phoneNumber ?? "",
                             "vcode" : otp]
                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: self.otpVC.isPhone ? CommonUrl.verify_phone : CommonUrl.verify_email, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
                    
                }, fromLoginPageCallBack: nil) { (resp) in
                    let data = AuthUserDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
                    self.userDataDB = data
                }
                break
            case .back:
                self.removeAndEmbdedLast()
                break
            }
        }
        
        otpVC.resendClickClosure = { [weak self] button in
            guard let `self` = self else {return}
            var param = ["email" : self.otpVC.email ?? "",
                         "mobile" : self.otpVC.phoneNumber ?? ""]
            if self.otpVC.isPhone{
                guard let code = self.otpVC.phone_code, code != "" else{
                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
                }
                param.updateValue(code, forKey : "country_code")
            }
            
            APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: true, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: self.otpVC.isPhone ? CommonUrl.resend_phone : CommonUrl.resend_email, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
            }, fromLoginPageCallBack: nil) { (resp) in
            }
        }
        
        loginPhoneVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .signIn:
                guard let phone = self.loginPhoneVC.txtPhone.text?.trim(), phone.count >= 8 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .mobileNo))
                }
                guard let password = self.loginPhoneVC.txtPassword.text?.trim(), password.count > 5 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .password))
                }
                
                guard var code = self.loginPhoneVC.btnPhoneCodeDropDown.titleLabel?.text else{
                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
                }
                code = code.replacingOccurrences(of: "+", with: "")
                code = code.replacingOccurrences(of: "▼", with: "").trim()
                
                guard code != "" else{
                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
                }
                
                let param = ["country_code" : code,
                             "mobile" : phone,
                             "password" : password]
                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.phone_login, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
                    
                }, fromLoginPageCallBack: nil) { (resp) in
                    let data = AuthUserDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
                    self.userDataDB = data
                }
                break
            case .back:
                self.removeAndEmbdedLast()
                break
            }
        }
        
        loginEmailVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .signIn:
//                guard let email = self.loginEmailVC.txtEmail.text?.trim(), email.isValidEmail() else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .email))
//                }
//                guard let password = self.loginEmailVC.txtPassword.text?.trim(), password.count > 5 else{
//                    return self.view.makeToast(CommonMessages.validationError(of: .password))
//                }
//                let param = ["email" : email,
//                             "password" : password]
//                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.email_login, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
//
//                }, fromLoginPageCallBack: nil) { (resp) in
//                    let data = AuthUserDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
//                    self.userDataDB = data
//                }
                //Bypass for now to home
                let mainNav = Helper.getVcObject(vcName: .MainNavigationController, StoryBoardName: .Main) as! MainNavigationController
                let home = Helper.getVcObject(vcName: .SwipeCardsVC, StoryBoardName: .Main) as! SwipeCardsVC
                mainNav.viewControllers = [home]
                Helper.replaceRootView(for: mainNav, animated: true)
                break
            case .back:
                self.removeAndEmbdedLast()
                break
            }
        }
        
        signUpPhoneVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .signUp:
                guard let phone = self.signUpPhoneVC.txtPhone.text?.trim(), phone.count >= 8 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .mobileNo))
                }
                guard let password = self.signUpPhoneVC.txtPassword.text?.trim(), password.count > 5 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .password))
                }
                
                guard var code = self.signUpPhoneVC.btnPhoneCodeDropDown.titleLabel?.text else{
                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
                }
                code = code.replacingOccurrences(of: "+", with: "")
                code = code.replacingOccurrences(of: "▼", with: "").trim()
                
                guard code != "" else{
                    return self.view.makeToast(CommonMessages.validationError(of: .country_code))
                }
                
                let param = ["name" : "",
                             "country_code" : code,
                             "mobile" : phone,
                             "email" : "",
                             "password" : password,
                             "cpassword" : password]
                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.signUp, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
                    
                }, fromLoginPageCallBack: nil) { (resp) in
                    if let vcode = (resp.dict?["result"] as? [String : Any])?["email_vcode"] as? NSNumber{
                        self.otpVC.otp = vcode.description
                        self.phone = phone
                        self.phonePassword = password
                        self.otpVC.isPhone = false
                        self.otpVC.phoneNumber = phone
                        self.otpVC.phone_code = code
                        self.removeAndEmbdedLast(withPusing: self.otpVC)
                    }else if let vcode = (resp.dict?["result"] as? [String : Any])?["email_vcode"] as? String{
                        self.otpVC.otp = vcode
                        self.phone = phone
                        self.otpVC.isPhone = false
                        self.otpVC.phoneNumber = phone
                        self.phonePassword = password
                        self.removeAndEmbdedLast(withPusing: self.otpVC)
                    }
                }
                break
            case .back:
                self.removeAndEmbdedLast()
                break
            }
        }
        
        signUpEmailVC.buttonClickClosure = { [weak self] button,clickType in
            guard let `self` = self else {return}
            switch clickType {
            case .signUp:
                guard let email = self.signUpEmailVC.txtEmail.text?.trim(), email.isValidEmail() else{
                    return self.view.makeToast(CommonMessages.validationError(of: .email))
                }
                guard let password = self.signUpEmailVC.txtPassword.text?.trim(), password.count > 5 else{
                    return self.view.makeToast(CommonMessages.validationError(of: .password))
                }
                let param = ["name" : "",
                             "email" : email,
                             "mobile" : "",
                             "password" : password,
                             "cpassword" : password]
                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: button, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.signUp, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
                    
                }, fromLoginPageCallBack: nil) { (resp) in
                    if let vcode = (resp.dict?["result"] as? [String : Any])?["email_vcode"] as? NSNumber{
                        self.otpVC.otp = vcode.description
                        self.otpVC.isPhone = false
                        self.otpVC.email = email
                        self.email = email
                        self.emailPassword = password
                        self.removeAndEmbdedLast(withPusing: self.otpVC)
                    }else if let vcode = (resp.dict?["result"] as? [String : Any])?["email_vcode"] as? String{
                        self.otpVC.otp = vcode
                        self.otpVC.isPhone = false
                        self.otpVC.email = email
                        self.email = email
                        self.emailPassword = password
                        self.removeAndEmbdedLast(withPusing: self.otpVC)
                    }
                }
                break
            case .back:
                self.removeAndEmbdedLast()
                break
            }
        }
        lastVCs = [loginRegisterVC]
        embed(loginRegisterVC)
    }
    
    private func googleLoginClick(){
//        DispatchQueue.main.async {
//            GIDSignIn.sharedInstance().presentingViewController = self
//            GIDSignIn.sharedInstance().delegate = self
//            GIDSignIn.sharedInstance().signIn()
//        }
    }
    
    private func facebookLoginClick(){
        DispatchQueue.main.async {
            let fbSDKManager: LoginManager = LoginManager()
            fbSDKManager.logOut()
            fbSDKManager.logIn(permissions: ["email"], from: self) { (result, error) in
                if error != nil {
                    self.view.makeToast("Failed to login using Facebook.")
                } else {
                    if let res = result {
                        if res.isCancelled {
                            self.view.makeToast("You have cancelled the login process.")
                        } else {
                            if res.grantedPermissions.contains("email") {
                                self.getFBUserData(hasEmail: true)
                            } else {
                                self.getFBUserData(hasEmail: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func goToHome(){
        let mainNav = Helper.getVcObject(vcName: .MainNavigationController, StoryBoardName: .Main) as! MainNavigationController
        let user = Helper.getVcObject(vcName: .ProfileVC, StoryBoardName: .Profile) as! ProfileVC
        let home = Helper.getVcObject(vcName: .SwipeCardsVC, StoryBoardName: .Main) as! SwipeCardsVC
        mainNav.viewControllers = [user,home]
        Helper.replaceRootView(for: mainNav, animated: true)
    }
    
    private func goToEditProfile(){
        let mainNav = Helper.getVcObject(vcName: .ProfileNavigationController, StoryBoardName: .Profile) as! ProfileNavigationController
        Helper.replaceRootView(for: mainNav, animated: true)
    }
    
    private func removeAndEmbdedLast(withPusing : UIViewController? = nil){
        if let push = withPusing{
            if !self.lastVCs.contains(push){
                self.lastVCs.append(push)
            }
            self.embed(push)
        }else{
            self.lastVCs.removeLast()
            if let vc = self.lastVCs.last{
                self.embed(vc)
            }
        }
    }
    
    func initializeVideoPlayerWithVideo() {
        
        let videoString:String? = Bundle.main.path(forResource: "justAfghans", ofType: "mp4")
        guard let unwrappedVideoPath = videoString else {return}
        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
        self.player = AVPlayer(url: videoUrl)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.frame = self.view.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(layer)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        player?.externalPlaybackVideoGravity = .resizeAspectFill
        player?.play()
        self.view.bringSubviewToFront(containerView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    deinit {
        print("Splash Video VC has deinit")
        if player?.currentItem?.observationInfo != nil{
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
    
    func embed(_ viewController:UIViewController?){
        guard let viewController = viewController else {return}
        guard !containerView.subviews.contains(viewController.view) else { return }
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            self.containerView.subviews.forEach({$0.alpha = 0})
        }, completion: { [self] _ in
            self.containerView.subviews.forEach({$0.removeFromSuperview()})
            viewController.willMove(toParent: self)
            viewController.view.frame = self.containerView.bounds
            self.containerView.addSubview(viewController.view)
            self.addChild(viewController)
            viewController.didMove(toParent: self)
            viewController.view.alpha = 0
            switch viewController{
            case self.signUpEmailVC :
                self.signUpEmailVC.txtEmail.text = email
                self.signUpEmailVC.txtPassword.text = emailPassword
                break
            case self.signUpPhoneVC :
                self.signUpPhoneVC.txtPhone.text = phone
                self.signUpPhoneVC.txtPassword.text = phonePassword
                break
            case self.loginEmailVC :
                self.loginEmailVC.txtEmail.text = email
                self.loginEmailVC.txtPassword.text = emailPassword
                break
            case self.loginPhoneVC :
                self.loginPhoneVC.txtPhone.text = phone
                self.loginPhoneVC.txtPassword.text = phonePassword
                break
            default:
                break
            }
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                viewController.view.alpha = 1
            }, completion: nil)
        })
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}



extension SplashVideoVC {
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let errorData = error {
//            self.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.ok, message: errorData.localizedDescription, completionHandler: {
//
//            })
//        } else {
//            let idToken = user.userID ?? ""
//            let fname = user.profile.givenName ?? ""
//            let image = user.profile.hasImage ? user.profile.imageURL(withDimension: 100)?.absoluteString ?? "" : ""
//            let lname = user.profile.familyName ?? ""
//            let email = user.profile.email ?? ""
//            let param = [
//                "email" : email,
//                "name" : [fname, lname].filter({$0 != ""}).joined(separator: " "),
//                "google_id" : idToken,
//                "image" : image,
//                "device_type" : platform,
//                "device_id" : UIDevice.current.identifierForVendor?.uuidString ?? "",
//                "firebase_reg_no" : CommonUserDefaults.accessInstance.get(forType: .fcmToken) ?? ""]
//            socialLoginOrSignup(socialType: 1, param: param)
//        }
//    }
    
    // MARK: - Facebook Login Function -
    fileprivate func getFBUserData(hasEmail: Bool) {
        let fbGraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.width(480).height(480)"])
        fbGraphRequest.start { [weak self] (connection, result, error) in
            if error != nil {
                self?.showSingleButtonAlertWithAction(title: CommonMessages.error, buttonTitle: CommonMessages.ok, message: error?.localizedDescription ?? CommonMessages.somethingWentWrong, completionHandler: {
                    
                })
            } else {
                let resDict = result as? NSDictionary ?? NSDictionary()
                print(resDict)
                var fbID = String()
                var email = String()
                var fname = String()
                var lname = String()
                var image = String()
                
                if let pictureData = resDict.value(forKey: "picture") as? NSDictionary {
                    if let data = pictureData.value(forKey: "data") as? NSDictionary{
                        image = data.value(forKey: "url") as? String ?? ""
                        print(image)
                    }
                }
                if resDict.value(forKey: "id") != nil {
                    fbID = resDict.value(forKey: "id") as? String ?? ""
                }
                if resDict.value(forKey: "email") != nil {
                    email = resDict.value(forKey: "email") as? String ?? ""
                }
                if resDict.value(forKey: "first_name") != nil {
                    fname = resDict.value(forKey: "first_name") as? String ?? ""
                }
                if resDict.value(forKey: "last_name") != nil {
                    lname = resDict.value(forKey: "last_name") as? String ?? ""
                }
                let param = ["email" : email,
                             "name" : [fname,lname].filter({$0 != ""}).joined(separator: " "),
                             "facebook_id" : fbID,
                             "image" : image,
                             "device_id" : UIDevice.current.identifierForVendor?.uuidString ?? "",
                             "firebase_reg_no" : CommonUserDefaults.accessInstance.get(forType: .fcmToken) ?? ""]
                self?.socialLoginOrSignup(socialType: 2, param: param)
            }
        }
    }
    
//    fileprivate func addSignInWithAppleButton(){
//        if #available(iOS 13.0, *) {
//            viewLoginWithApple.layer.borderColor = UIColor.black.cgColor
//            viewLoginWithApple.layer.borderWidth = 1
//            viewLoginWithApple.layer.cornerRadius = viewLoginWithApple.frame.width / 2
//            appleSignIn.loginWithApple(view:viewLoginWithApple, completionBlock: { [weak self](userInfo, error) in
//                if let user = userInfo{
//                    let param = ["email" : user.email,
//                                 "name" : [user.firstName,user.lastName].filter({$0 != ""}).joined(separator: " "),
//                                 "social_id" : user.userid,
//                                 "user_from" : "A"]
//                    self?.socialLogin(param: param)
//                }else if let err = error{
//                    if err.code == 1001{
//                        self?.view.makeToast("You canceled the apple login process.")
//                    }else if err.code == 1000{
//                        self?.view.makeToast("You apple login has been failed.")
//                    }else{
//                        self?.view.makeToast("Something went wrong when login.")
//                    }
//                }else{
//                    self?.view.makeToast("Something went wrong when login.")
//                }
//            })
//        }else {
//            viewLoginWithApple.isHidden = true
//        }
//    }
    
    func socialLoginOrSignup(socialType: Int, param: [String : String]){
        self.view.makeToastActivity(self.view.center)
        var url = String()
        switch socialType {
        case 1:
            url = CommonUrl.google_login
        case 2:
            url = CommonUrl.facebook_login
        case 3:
            url = CommonUrl.appleLogin
        default:
            return
        }
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: url, isTokenNeeded: false, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil){ [weak self] (resp) in
            self?.userDataDB = AuthUserDataModel(dictionary: resp.responseDict as? NSDictionary ?? NSDictionary())
        }
    }
}
