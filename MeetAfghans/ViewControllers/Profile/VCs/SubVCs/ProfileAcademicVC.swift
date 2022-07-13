//
//  ProfileAcademicVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileAcademicVC: UIViewController {
    
    @IBOutlet weak var txtAcademic : UITextField!
    
    private let arr = ["School Level","High School","Graduate","Post Graduate","Under Graduate","Diploma","Master Degree","Doctorate","P.Hd Scolar"]
    private var dropDown : DropDown?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAcademic.delegate = self
        txtAcademic.addTarget(self, action: #selector(txtEditingChange), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtAcademic.text = CommonUserDefaults.accessInstance.get(forType: .userEducation)
        dropDown = self.setDropDown(from: txtAcademic,direction: .top){ [weak self] (item,index) in
            self?.txtAcademic.text = self?.dropDown?.dataSource[index]
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
        guard let education = self.txtAcademic.text?.trim(), education.count > 2 else{
            return self.view.makeToast(CommonMessages.validationError(of: .academic))
        }
        
        if CommonUserDefaults.accessInstance.get(forType: .userEducation) == education{
            let vc = Helper.getVcObject(vcName: .ProfileMaritalStatusVC, StoryBoardName: .Profile) as! ProfileMaritalStatusVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["level_of_education" : education]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(education, forType: .userEducation)
                let vc = Helper.getVcObject(vcName: .ProfileMaritalStatusVC, StoryBoardName: .Profile) as! ProfileMaritalStatusVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}


extension ProfileAcademicVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDown?.dataSource = arr
        dropDown?.show()
    }
    
}
