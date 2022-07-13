//
//  ProfileHeightVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileHeightVC: UIViewController{
    
    @IBOutlet weak var heightPicker : UIPickerView!
    
    lazy var arr = (120...220).map({"\($0)"})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        heightPicker.reloadAllComponents()
        let middle = ((arr.count / 2) > 0) ? ((arr.count / 2) - 1) : (arr.count / 2)
        if let height = CommonUserDefaults.accessInstance.get(forType: .userHeight), height != ""{
            heightPicker.selectRow(arr.firstIndex(where: {$0 == height}) ?? middle, inComponent: 0, animated: true)
        }else{
            heightPicker.selectRow(middle, inComponent: 0, animated: true)
        }
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        guard arr[self.heightPicker.selectedRow(inComponent: 0)].count > 2 else{
            return self.view.makeToast(CommonMessages.validationError(of: .height))
        }
        
        if CommonUserDefaults.accessInstance.get(forType: .userHeight) == arr[self.heightPicker.selectedRow(inComponent: 0)]{
            let vc = Helper.getVcObject(vcName: .ProfilePartnerGenderVC, StoryBoardName: .Profile) as! ProfilePartnerGenderVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["height" : arr[self.heightPicker.selectedRow(inComponent: 0)]]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(self.arr[self.heightPicker.selectedRow(inComponent: 0)], forType: .userHeight)
                let vc = Helper.getVcObject(vcName: .ProfilePartnerGenderVC, StoryBoardName: .Profile) as! ProfilePartnerGenderVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension ProfileHeightVC :  UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arr[row]) cm"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: arr[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return attributedString
    }
    
}
