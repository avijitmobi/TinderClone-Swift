//
//  ProfileVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 19/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblAge : UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.get_profile_details, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            let userData = UserProfileBaseModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
            let user = userData?.result?.user
            CommonUserDefaults.accessInstance.save(user?.id?.description, forType: .userID)
            CommonUserDefaults.accessInstance.save(user?.email, forType: .userEmail)
            CommonUserDefaults.accessInstance.save(user?.mobile, forType: .userMobile)
            CommonUserDefaults.accessInstance.save(user?.gender, forType: .userGender)
            CommonUserDefaults.accessInstance.save(user?.dob, forType: .userDOB)
            CommonUserDefaults.accessInstance.save(user?.height, forType: .userHeight)
            CommonUserDefaults.accessInstance.save(user?.level_of_education, forType: .userEducation)
            CommonUserDefaults.accessInstance.save(user?.living, forType: .userProfession)
            CommonUserDefaults.accessInstance.save(user?.nick_name, forType: .userNickName)
            CommonUserDefaults.accessInstance.save(user?.marital_status, forType: .userMaritalStatus)
            CommonUserDefaults.accessInstance.save(user?.find_gender, forType: .userPrefGender)
            CommonUserDefaults.accessInstance.save(userData?.result?.age, forType: .userAge)
            CommonUserDefaults.accessInstance.save(userData?.result?.user_img?.filter({($0.file_name ?? "" != "") || (($0.file_name?.contains(".jpg") ?? false) || ($0.file_name?.contains(".png") ?? false))}).first?.file_name, forType: .userPhoto)
            self.lblName.text = CommonUserDefaults.accessInstance.get(forType: .userNickName) ?? "No Name"
            self.lblAge.text = "Age " + (CommonUserDefaults.accessInstance.get(forType: .userAge) ?? "18")
            self.imgProfile.getImage(withUrl: (CommonUrl.profileImageURL)+(CommonUserDefaults.accessInstance.get(forType: .userPhoto) ?? ""),  placeHolder: CommonImage.placeholder, imgContentMode: .scaleAspectFill, imgContentModeOfPlaceHolder: .scaleAspectFill)
        }
        
    }
    
    @IBAction func btnEditProfile(_ from : TransitionButton){
        let nav = Helper.getVcObject(vcName: .ProfileNavigationController, StoryBoardName: .Profile) as! ProfileNavigationController
        nav.needToEdit = false
        nav.modalPresentationStyle = .overCurrentContext
        nav.modalTransitionStyle = .coverVertical
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func btnAll(_ from : UIButton){
        if from.tag == 0{
            let vc = Helper.getVcObject(vcName: .UserListVC, StoryBoardName: .Chat) as! UserListVC
            vc.userType = .like
            self.checkAndPushPop(vc, navigationController: self.navigationController)
        }else if from.tag == 1{
            let chat = Helper.getVcObject(vcName: .ChatListVC, StoryBoardName: .Chat) as! ChatListVC
            self.checkAndPushPop(chat,navigationController: self.navigationController)
        }else if from.tag == 2{
            
        }else if from.tag == 3{
            let vc = Helper.getVcObject(vcName: .UserListVC, StoryBoardName: .Chat) as! UserListVC
            vc.userType = .dislike
            self.checkAndPushPop(vc, navigationController: self.navigationController)
        }else if from.tag == 4{
            let vc = Helper.getVcObject(vcName: .UserListVC, StoryBoardName: .Chat) as! UserListVC
            vc.userType = .blocks
            self.checkAndPushPop(vc, navigationController: self.navigationController)
        }else if from.tag == 5{
            
        }else if from.tag == 6{
            let vc = Helper.getVcObject(vcName: .AdsVC, StoryBoardName: .Main) as! AdsVC
            self.checkAndPushPop(vc, navigationController: self.navigationController)
        }
    }
    
    @IBAction func btnInviteFriends(_ from : TransitionButton){
        
    }
    
    @IBAction func btnLogout(_ from : TransitionButton){
        self.showTwoButtonAlertWithRightAction(title: "Logout", buttonTitleLeft: "No", buttonTitleRight: "Yes", message: "Are you sure to logout from this app?") {
            let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
            CommonUserDefaults.accessInstance.removeAll()
            Helper.replaceRootView(for: mainNav, animated: true)
        }
    }
    
    @IBAction func btnMySettings(_ from : UIButton){
        let vc = Helper.getVcObject(vcName: .ProfilePhotoMediaVC, StoryBoardName: .Profile) as! ProfilePhotoMediaVC
        vc.itsForSettings = true
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = false
        nav.modalTransitionStyle = .coverVertical
        nav.modalPresentationStyle = .overFullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
