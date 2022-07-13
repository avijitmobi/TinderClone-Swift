//
//  SignUpPhoneVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 13/01/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class SignUpPhoneVC: UIViewController {
    
    enum ButtonType {
        case signUp
        case back
    }
    
    @IBOutlet weak var txtTermsAndPrivacy : UITextView!
    @IBOutlet weak var txtPhone : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var btnPhoneCodeDropDown : UIButton!
    
    let text = "By Signing up, you agree to our Terms Of Services and Privacy Policy"
    
    var buttonClickClosure : ((TransitionButton?,ButtonType)->())?
    var countryClickClosure : ((UIButton?)->())?
    var parentVC : SplashVideoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underlinetermsAndPolicy()
    }
    
    private func underlinetermsAndPolicy(){
        self.txtTermsAndPrivacy.delegate = self
        self.txtTermsAndPrivacy.linkTextAttributes = [NSAttributedString.Key.foregroundColor: CommonColor.ButtonGradientFirst]
        let attributedString = NSMutableAttributedString(string: text)
        var foundRange = attributedString.mutableString.range(of: "Terms Of Services".localizedWithLanguage)
        attributedString.addAttribute(NSAttributedString.Key.link, value: "tnc", range: foundRange)
        foundRange = attributedString.mutableString.range(of: "Privacy Policy".localizedWithLanguage)
        attributedString.addAttribute(NSAttributedString.Key.link, value: "pp", range: foundRange)
        txtTermsAndPrivacy.attributedText = attributedString
        txtTermsAndPrivacy.font = UIFont(name: "OpenSans-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        txtTermsAndPrivacy.textColor = .white
        txtTermsAndPrivacy.textAlignment = .center
    }
    
    @IBAction func btnBack(_ from : UIButton){
        buttonClickClosure?(nil,ButtonType.back)
    }
    
    @IBAction func btnSignUp(_ from : TransitionButton){
        buttonClickClosure?(from,ButtonType.signUp)
    }
    
    @IBAction func btnPhoneCodeDropdown(_ sender : UIButton){
        countryClickClosure?(sender)
    }
}



extension SignUpPhoneVC  :  UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString == "pp") {
            parentVC?.openSafariView(withUrl: CommonUrl.privacy_policy, withColor: CommonColor.ButtonGradientFirst)
        }else if (URL.absoluteString == "tnc"){
            parentVC?.openSafariView(withUrl: CommonUrl.terms_conditions, withColor: CommonColor.ButtonGradientFirst)
        }
        return false
    }
}


