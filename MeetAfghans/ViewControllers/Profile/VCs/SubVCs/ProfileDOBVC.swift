//
//  ProfileDOBVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit


class ProfileDOBVC: UIViewController {
    
    @IBOutlet weak var datePicker : UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDate()
    }
    
    fileprivate func setUpDate() {
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        let calender = Calendar.current
        let date =  calender.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        if let dateS = CommonUserDefaults.accessInstance.get(forType: .userDOB), dateS != ""{
            let df = DateFormatter()
            df.dateFormat = CommonString.dobFormat
            datePicker.setDate(df.date(from: dateS) ?? date, animated: true)
        }else{
            datePicker.setDate(date, animated: true)
        }
        datePicker.maximumDate = Date()
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        
        guard Date().isLaterThan(self.datePicker.date) else{
            return self.view.makeToast(CommonMessages.validationError(of: .dateOfBirth))
        }
        
        let df = DateFormatter()
        df.dateFormat = CommonString.dobFormat
        
        if CommonUserDefaults.accessInstance.get(forType: .userDOB) == df.string(from: self.datePicker.date){
            let vc = Helper.getVcObject(vcName: .ProfileOccupationVC, StoryBoardName: .Profile) as! ProfileOccupationVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["dob" : df.string(from: self.datePicker.date)]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(df.string(from: self.datePicker.date), forType: .userDOB)
                let vc = Helper.getVcObject(vcName: .ProfileOccupationVC, StoryBoardName: .Profile) as! ProfileOccupationVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
