//
//  ProfileGenderVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 30/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileGenderVC: UIViewController {
    
    @IBOutlet weak var lblSelectGender : UILabel!
    
    let arr = ["Male","Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let gender = CommonUserDefaults.accessInstance.get(forType: .userGender), gender != "" else {return}
        lblSelectGender.text = gender == "F" ? "Female" : "Male"
    }
    
    
    @IBAction func btnChooseGender(_ from : UIButton){
        showDropDown(with: arr, from: from, direction: .any) { (str, index) in
            self.lblSelectGender.text = str
        }
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        guard let gender = self.lblSelectGender.text?.trim(), arr.contains(gender) else{
            return self.view.makeToast(CommonMessages.validationError(of: .gender))
        }
        
        if let gen = CommonUserDefaults.accessInstance.get(forType: .userGender), gen != "", (gen == "F" ? "Female" : "Male") == gender{
            let vc = Helper.getVcObject(vcName: .ProfileDOBVC, StoryBoardName: .Profile) as! ProfileDOBVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["gender" : gender == "Male" ? "M" : "F"]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(gender == "Male" ? "M" : "F", forType: .userGender)
                let vc = Helper.getVcObject(vcName: .ProfileDOBVC, StoryBoardName: .Profile) as! ProfileDOBVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
