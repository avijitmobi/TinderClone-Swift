//
//  LoginVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 04/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    enum ButtonType {
        case signInWithGoogle
        case signInWithEmail
        case signInWithFacebook
        case signInWithPhone
        case back
    }
    
    @IBOutlet weak var txtTermsAndPrivacy : UITextView!
    
    let text = "By Logging in, you agree to our Terms Of Services and Privacy Policy"
    
    var buttonClickClosure : ((ButtonType)->())?
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
        buttonClickClosure?(ButtonType.back)
    }
    
    @IBAction func btnLogin(_ from : UIButton){
        switch from.tag {
        case 0:
            buttonClickClosure?(ButtonType.signInWithEmail)
        case 1:
            buttonClickClosure?(ButtonType.signInWithPhone)
        case 2:
            buttonClickClosure?(ButtonType.signInWithGoogle)
        case 3:
            buttonClickClosure?(ButtonType.signInWithGoogle)
        default:
            break
        }
    }
    
}



extension LoginVC  :  UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString == "pp") {
            parentVC?.openSafariView(withUrl: CommonUrl.privacy_policy, withColor: CommonColor.ButtonGradientFirst)
        }else if (URL.absoluteString == "tnc"){
            parentVC?.openSafariView(withUrl: CommonUrl.terms_conditions, withColor: CommonColor.ButtonGradientFirst)
        }
        return false
    }
}
