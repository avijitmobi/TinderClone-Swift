//
//  OTPVerificationVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 16/01/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class OTPVerificationVC: UIViewController {
    
    enum ButtonType {
        case verifyNow
        case back
    }
    
    @IBOutlet weak var txtOTP : DPOTPView!
    
    var buttonClickClosure : ((TransitionButton?,ButtonType)->())?
    var resendClickClosure : ((UIButton?)->())?
    var otp : String?
    var isPhone : Bool = false
    var phone_code : String?
    var phoneNumber : String?
    var email : String?
    var parentVC : SplashVideoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtOTP.text = otp
    }
    
    @IBAction func btnBack(_ from : UIButton){
        buttonClickClosure?(nil,ButtonType.back)
    }
    
    @IBAction func btnVerify(_ from : TransitionButton){
        buttonClickClosure?(from,ButtonType.verifyNow)
    }
    
    @IBAction func btnResend(_ from : UIButton){
        resendClickClosure?(from)
    }
}



