//
//  ProfileMaritalStatusVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileMaritalStatusVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var lblMaritalStatus : UILabel!
    
    let arr = ["Single","Married"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let marital = CommonUserDefaults.accessInstance.get(forType: .userMaritalStatus), marital != "" else {return}
        lblMaritalStatus.text = marital == "M" ? "Married" : "Single"
    }
    
    
    @IBAction func btnChooseMaritalStatus(_ from : UIButton){
        showDropDown(with: arr, from: from, direction: .any) { (str, index) in
            self.lblMaritalStatus.text = str
        }
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        guard let status = self.lblMaritalStatus.text?.trim(), arr.contains(status) else{
            return self.view.makeToast(CommonMessages.validationError(of: .marital))
        }
        
        if let marital = CommonUserDefaults.accessInstance.get(forType: .userMaritalStatus), marital != "", (marital == "M" ? "Married" : "Single") == status{
            let vc = Helper.getVcObject(vcName: .ProfileHeightVC, StoryBoardName: .Profile) as! ProfileHeightVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["marital_status" : status == "Married" ? "M" : "S"]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(status == "Married" ? "M" : "S", forType: .userMaritalStatus)
                let vc = Helper.getVcObject(vcName: .ProfileHeightVC, StoryBoardName: .Profile) as! ProfileHeightVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
