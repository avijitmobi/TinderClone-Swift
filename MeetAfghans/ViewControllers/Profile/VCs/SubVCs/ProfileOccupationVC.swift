//
//  ProfileOccupationVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileOccupationVC: UIViewController {
    
    @IBOutlet weak var txtOccupation : UITextField!
    
    private let arr = ["Student", "Engineer", "Doctor"]
    
    private var dropDown : DropDown?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtOccupation.delegate = self
        txtOccupation.addTarget(self, action: #selector(txtEditingChange), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtOccupation.text = CommonUserDefaults.accessInstance.get(forType: .userProfession)
        dropDown = self.setDropDown(from: txtOccupation,direction: .top){ [weak self] (item,index) in
            self?.txtOccupation.text = self?.dropDown?.dataSource[index]
            self?.dropDown?.hide()
        }
    }
    
    @objc func txtEditingChange(_ from : UITextField){
        dropDown?.dataSource = arr.filter({$0.localizedCaseInsensitiveContains(from.text ?? "")})
        if dropDown?.isHidden ?? false{
            dropDown?.show()
        }
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        guard let occu = self.txtOccupation.text?.trim(), occu.count > 2 else{
            return self.view.makeToast(CommonMessages.validationError(of: .occupation))
        }
        
        if CommonUserDefaults.accessInstance.get(forType: .userProfession) == occu{
            let vc = Helper.getVcObject(vcName: .ProfileAcademicVC, StoryBoardName: .Profile) as! ProfileAcademicVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["living" : occu]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(occu, forType: .userProfession)
                let vc = Helper.getVcObject(vcName: .ProfileAcademicVC, StoryBoardName: .Profile) as! ProfileAcademicVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}


extension ProfileOccupationVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown?.dataSource = arr
        dropDown?.show()
    }
    
}
