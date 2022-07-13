//
//  ProfilePartnerGenderVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfilePartnerGenderVC: UIViewController {
    
    @IBOutlet weak var lblSelectGender : UILabel!
    
    let arr = ["Male","Female","Both"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let pref = CommonUserDefaults.accessInstance.get(forType: .userPrefGender), pref != "" else {return}
        lblSelectGender.text = pref == "F" ? "Female" : pref == "M" ? "Male" : "Both"
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
        let pref = CommonUserDefaults.accessInstance.get(forType: .userPrefGender)
        if let pref = pref, pref != "",(pref == "F" ? "Female" : pref == "M" ? "Male" : "Both") == gender{
            let vc = Helper.getVcObject(vcName: .ProfilePhotoMediaVC, StoryBoardName: .Profile) as! ProfilePhotoMediaVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["find_gender" : gender == "Male" ? "M" :  gender == "Female" ? "F" : "B"]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(gender == "Male" ? "M" :  gender == "Female" ? "F" : "B", forType: .userPrefGender)
                let vc = Helper.getVcObject(vcName: .ProfilePhotoMediaVC, StoryBoardName: .Profile) as! ProfilePhotoMediaVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
