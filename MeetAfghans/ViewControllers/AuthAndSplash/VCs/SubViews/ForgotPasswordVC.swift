//
//  ForgotPasswordVC.swift
//  MeetAfghans
//
//  Created by Codelogicx on 22/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    enum ButtonType {
        case forgotPassword
        case back
    }
    
    @IBOutlet weak var txtPhone : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var btnPhoneCodeDropDown : UIButton!
    
    var buttonClickClosure : ((TransitionButton?,ButtonType)->())?
    var countryClickClosure : ((UIButton?)->())?
    var parentVC : SplashVideoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnBack(_ from : UIButton){
        buttonClickClosure?(nil,ButtonType.back)
    }
    
    @IBAction func btnPhoneCodeDropdown(_ sender : UIButton){
        countryClickClosure?(sender)
    }
    
    @IBAction func btnResetPassword(_ sender : TransitionButton){
        countryClickClosure?(sender)
    }
}



extension ForgotPasswordVC  :  UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString == "pp") {
            parentVC?.openSafariView(withUrl: CommonUrl.privacy_policy, withColor: CommonColor.ButtonGradientFirst)
        }else if (URL.absoluteString == "tnc"){
            parentVC?.openSafariView(withUrl: CommonUrl.terms_conditions, withColor: CommonColor.ButtonGradientFirst)
        }
        return false
    }
}



