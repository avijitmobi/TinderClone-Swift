//
//  ProfileNickNameVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 25/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileNickNameVC: UIViewController {
    
    @IBOutlet weak var txtNickName : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if (navigationController as? ProfileNavigationController)?.needToEdit ?? false{
            loadEditMode()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtNickName.text = CommonUserDefaults.accessInstance.get(forType: .userNickName)
    }
    
    private func loadEditMode(){
        let arr : [UserDefaultType] = [.userNickName,.userGender,.userDOB,.userProfession,.userEducation,.userMaritalStatus,.userHeight,.userPrefGender].filter({CommonUserDefaults.accessInstance.get(forType: $0) ?? "" == ""})
        switch arr.first{
        case .userNickName :
            break
        case .userGender:
            let vc = Helper.getVcObject(vcName: .ProfileGenderVC, StoryBoardName: .Profile) as! ProfileGenderVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userDOB:
            let vc = Helper.getVcObject(vcName: .ProfileDOBVC, StoryBoardName: .Profile) as! ProfileDOBVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userProfession:
            let vc = Helper.getVcObject(vcName: .ProfileOccupationVC, StoryBoardName: .Profile) as! ProfileOccupationVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userEducation:
            let vc = Helper.getVcObject(vcName: .ProfileAcademicVC, StoryBoardName: .Profile) as! ProfileAcademicVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userMaritalStatus:
            let vc = Helper.getVcObject(vcName: .ProfileMaritalStatusVC, StoryBoardName: .Profile) as! ProfileMaritalStatusVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userHeight:
            let vc = Helper.getVcObject(vcName: .ProfileHeightVC, StoryBoardName: .Profile) as! ProfileHeightVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        case .userPrefGender:
            let vc = Helper.getVcObject(vcName: .ProfilePartnerGenderVC, StoryBoardName: .Profile) as! ProfilePartnerGenderVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
            break
        default:
            break
        }
    }
    

    @IBAction func btnContinue(_ from : TransitionButton){
        
        guard let nickName = self.txtNickName.text?.trim(), nickName.count > 2 else{
            return self.view.makeToast(CommonMessages.validationError(of: .nickName))
        }
        
        if CommonUserDefaults.accessInstance.get(forType: .userNickName) == nickName{
            let vc = Helper.getVcObject(vcName: .ProfileGenderVC, StoryBoardName: .Profile) as! ProfileGenderVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let param = ["nick_name" : nickName]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                CommonUserDefaults.accessInstance.save(nickName, forType: .userNickName)
                let vc = Helper.getVcObject(vcName: .ProfileGenderVC, StoryBoardName: .Profile) as! ProfileGenderVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
