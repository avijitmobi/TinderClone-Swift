//
//  ProfilePhotoMediaVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 02/01/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfilePhotoMediaVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    struct UpdatedImageList {
        var file_name : String?
        var file_order : Int?
    }
    
    @IBOutlet weak var collectionViewPhotoMedia : UICollectionView!
    @IBOutlet weak var heightCollectionViewPhotoMedia : NSLayoutConstraint!
    @IBOutlet weak var needGlobalSearch : UISwitch!
    @IBOutlet weak var txtAbout : IQTextView!
    @IBOutlet weak var txtPassion : UITextField!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var txtJobTitle : UITextField!
    @IBOutlet weak var txtCompany : UITextField!
    @IBOutlet weak var txtSchoolCollege : UITextField!
    @IBOutlet weak var txtCity : UITextField!
    @IBOutlet weak var needToShowAge : UISwitch!
    @IBOutlet weak var needDistanceInvisible : UISwitch!
    @IBOutlet weak var rangeSeeker : RangeSeekSlider!
    @IBOutlet weak var topSpace : NSLayoutConstraint!
    @IBOutlet weak var btnMedia : TransitionButton!
    
    @IBOutlet weak var viewDeactivate : UIView!
    @IBOutlet weak var viewDelete : UIView!
    
    private var imagePicker : EasyImagePicker?
    private var imageOrder : Int = 1
    var itsForSettings = false
    var videoUrl : URL?{
        didSet{
            if let _ = videoUrl{
                btnMedia.setTitle("Video Added", for: .normal)
            }
        }
    }
    
    var userData : UserProfileBaseModel?{
        didSet{
            updateData()
        }
    }
    private var imagesList : [UpdatedImageList]?

    override func viewDidLoad() {
        super.viewDidLoad()
        rangeSeeker.delegate = self
        topSpace.constant = itsForSettings ? 0 : 155
        if itsForSettings{
            self.navigationController?.navigationBar.barTintColor = .black
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.tintColor = CommonColor.ButtonGradientFirst
            self.navigationItem.title = "Settings"
            var barButton : UIBarButtonItem{
                return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
            }
            if #available(iOS 13.0, *) {
                self.navigationItem.setRightBarButton(barButton, animated: true)
            } else {
                self.navigationItem.setRightBarButton(barButton, animated: true)
            }
        }
        [viewDeactivate,viewDelete].forEach({$0?.isHidden = !itsForSettings})
        updateData()
        imagePicker = EasyImagePicker(presentationController: self, delegate: self)
    }
    
    private func updateData(){
        imagesList = [UpdatedImageList]()
        let data = userData?.result?.user
        txtCity.text = data?.city
        txtAbout.text = data?.about
        txtPassion.text = data?.passion
        txtSchoolCollege.text = data?.college_school
        txtCompany.text = data?.company
        txtJobTitle.text = data?.job_title
        rangeSeeker.selectedMinValue = (CGFloat((data?.min_km ?? "0").toFloat()) <= rangeSeeker.minValue) ? rangeSeeker.minValue : CGFloat((data?.min_km ?? "0").toFloat())
        rangeSeeker.selectedMaxValue = (CGFloat((data?.max_km ?? "300").toFloat()) >= rangeSeeker.maxValue) ? rangeSeeker.maxValue : CGFloat((data?.max_km ?? "300").toFloat())
        needToShowAge.isOn = data?.show_my_age == "Y"
        needDistanceInvisible.isOn = data?.my_distance_visible == "Y"
        needGlobalSearch.isOn = data?.is_global == "Y"
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
        (0...8).forEach { (it) in
            if let index = userData?.result?.user_img?.firstIndex(where: {$0.file_order == (it + 1)}){
                imagesList?.append(UpdatedImageList(file_name: userData?.result?.user_img?[index].file_name, file_order: it+1))
            }else{
                imagesList?.append(UpdatedImageList())
            }
        }
        CommonUserDefaults.accessInstance.save(userData?.result?.user_img?.filter({($0.file_name ?? "" != "") || (($0.file_name?.contains(".jpg") ?? false) || ($0.file_name?.contains(".png") ?? false))}).first?.file_name, forType: .userPhoto)
        collectionViewPhotoMedia.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserImages()
    }
    
    deinit {
        print("\(self) has deinit")
    }
    
    private func getUserImages(){
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: true, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.get_profile_details, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            self.userData = UserProfileBaseModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
        }
    }
    
    @objc func close(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        
        guard let about = self.txtAbout.text?.trim(), about != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .about))
        }
        
//        guard let city = self.txtCity.text?.trim(), city != "" else{
//            return self.view.makeToast(CommonMessages.validationError(of: .city))
//        }
//
//        guard let passion = self.txtPassion.text?.trim(), passion != "" else{
//            return self.view.makeToast(CommonMessages.validationError(of: .passion))
//        }
//
//        guard let job = self.txtJobTitle.text?.trim(), job != "" else{
//            return self.view.makeToast(CommonMessages.validationError(of: .job_title))
//        }
//
//        guard let company = self.txtCompany.text?.trim(), company != "" else{
//            return self.view.makeToast(CommonMessages.validationError(of: .company))
//        }
//
//        guard let college = self.txtSchoolCollege.text?.trim(), passion != "" else{
//            return self.view.makeToast(CommonMessages.validationError(of: .college_school))
//        }
        
        let param = ["city" : self.txtCity.text?.trim() ?? "",
                     "is_global" : needGlobalSearch.isOn ? "Y" : "N",
                     "min_km" : Int(rangeSeeker.selectedMinValue).description,
                     "max_km" : Int(rangeSeeker.selectedMaxValue).description,
                     "about" : about,
                     "passion" : self.txtPassion.text?.trim() ?? "",
                     "job_title" : self.txtJobTitle.text?.trim() ?? "",
                     "company" : self.txtCompany.text?.trim() ?? "",
                     "college_school" : self.txtSchoolCollege.text?.trim() ?? "",
                     "show_my_age" : needToShowAge.isOn ? "Y" : "N",
                     "my_distance_visible" : needDistanceInvisible.isOn ? "Y" : "N"]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: from, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
            
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error == nil{
                if keyWindow?.rootViewController is MainNavigationController{
                    self.dismiss(animated: true, completion: nil)
                }else{
                    let mainNav = Helper.getVcObject(vcName: .MainNavigationController, StoryBoardName: .Main) as! MainNavigationController
                    let user = Helper.getVcObject(vcName: .ProfileVC, StoryBoardName: .Profile) as! ProfileVC
                    let home = Helper.getVcObject(vcName: .SwipeCardsVC, StoryBoardName: .Main) as! SwipeCardsVC
                    mainNav.viewControllers = [user,home]
                    Helper.replaceRootView(for: mainNav, animated: true)
                }
            }
        }
    }
    
    @IBAction func btnAddMedia(_ from : UIButton){
        imagePicker?.present(from: from, mediaType: .video, onViewController: self)
    }
    
    @IBAction func btnDeactivateAccount(_ from : UIButton){
        self.showTwoButtonAlertWithRightAction(title: "Confirm", buttonTitleLeft: "No", buttonTitleRight: "Yes", message: "Are you sure to deactivate your account? You can reactivate your account anytime by contacting us.") {
            APIReqeustManager.sharedInstance.serviceCall(param: ["user_status" : "I"], method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.user_deactivate, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
                if succ{
                    let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
                    CommonUserDefaults.accessInstance.removeAll()
                    Helper.replaceRootView(for: mainNav, animated: true)
                }
            }, fromLoginPageCallBack: nil) { _ in }
        }
    }
    
    @IBAction func btnDeleteAccount(_ from : UIButton){
        self.showTwoButtonAlertWithRightAction(title: "Confirm", buttonTitleLeft: "No", buttonTitleRight: "Yes", message: "Are you sure to delete your account? You can not revert back your account once deleted.") {
            APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.user_delete, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: true, actionErrorOrSuccess: { (succ, str) in
                if succ{
                    let mainNav = Helper.getVcObject(vcName: .AuthNavigationController, StoryBoardName: .Main) as! AuthNavigationController
                    CommonUserDefaults.accessInstance.removeAll()
                    Helper.replaceRootView(for: mainNav, animated: true)
                }
            }, fromLoginPageCallBack: nil) { _ in }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCollectionCell", for: indexPath) as! ProfilePhotoCollectionCell
        if let img = imagesList?[indexPath.row].file_name, img != ""{
            cell.btnDeleteOrAdd.isSelected = true
            cell.imgProfilePhoto.getImage(withUrl: (CommonUrl.profileImageURL)+img, placeHolder: nil, imgContentMode: .scaleAspectFill, imgContentModeOfPlaceHolder: .scaleAspectFit)
        }else{
            cell.imgProfilePhoto.image = nil
            cell.imgProfilePhoto.backgroundColor = .white
            cell.btnDeleteOrAdd.isSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        let items : CGFloat = 3
        let minItemSpacing : CGFloat = 10
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * (items - 1))
        let cellWidth = (collectionWidth - totalSpace)/items
        let cellHeight = cellWidth + (cellWidth*0.2)
        heightCollectionViewPhotoMedia.constant = (cellHeight*(CGFloat(9)/items)) + ((items+1)*minItemSpacing)
        return CGSize(width: Int(cellWidth), height: Int(cellHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ProfilePhotoCollectionCell
        for i in 0..<(indexPath.row){
            if imagesList?[i].file_name ?? "" == ""{
                return self.view.makeToast("Please upload previous images first.")
            }
        }
        imageOrder = imagesList?[indexPath.row].file_order ?? (indexPath.row+1)
        if imagesList?[indexPath.row].file_name ?? "" != ""{
            self.showTwoButtonAlertWithRightAction(title: "Confirm", buttonTitleLeft: "No", buttonTitleRight: "Yes", message: "Are you sure to remove this photo?") {
                let param = ["file_order" : self.imageOrder.description]
                APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.remove_profile_picture, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in
                    
                }, fromLoginPageCallBack: nil) { [weak self] (resp) in
                    if resp.error == nil{
                        self?.getUserImages()
                    }
                }
            }
        }else {
            imagePicker?.present(from: cell?.imgProfilePhoto ?? self.view, mediaType: .images, onViewController: self)
        }
    }
    
    private func uploadVideo(){
        showProgressBarInAlert { (alert, progress) in
            APIReqeustManager.sharedInstance.uploadWithAlamofire(multipart: { (multiPartData) in
                multiPartData.append("10".data(using: .utf8) ?? Data(), withName: "file_order")
                if let url = self.videoUrl{
                    multiPartData.append(url, withName: "image")
                }
            }, url: CommonUrl.upload_file_image, method: .post, loadingButton: nil, loaderNeed: false, needViewHideShowAfterLoading: nil, vc: self, isTokenNeeded: true, progressValue: { (progressValue) in
                progress.progress = Float(progressValue)
                alert.message = "\(Int(progressValue*100))%"
            }, isErrorAlertNeeded: true,errorBlock : {alert.dismiss(animated: true)}, actionErrorOrSuccess: { (isSuccess, message) in
                
            }, fromLoginPageCallBack: nil) { [weak self] (dict, error) in
                alert.dismiss(animated: true)
                if error == nil{
                    self?.getUserImages()
                    self?.showSingleButtonWithMessage(title: "Success", message: "Your photo has been uploaded successfully.", buttonName: "Okay")
                }
            }
        }
    }
    
    private func uploadPhoto(with: UIImage){
        showProgressBarInAlert { (alert, progress) in
            APIReqeustManager.sharedInstance.uploadWithAlamofire(multipart: { (multiPartData) in
                multiPartData.append(with.jpegData(compressionQuality: 1) ?? Data(), withName: "file_name", fileName: "image", mimeType: "image/jpeg")
                multiPartData.append(self.imageOrder.description.data(using: .utf8) ?? Data(), withName: "file_order")
                if let url = self.videoUrl{
                    multiPartData.append(url, withName: "file_name")
                }
            }, url: CommonUrl.upload_file_image, method: .post, loadingButton: nil, loaderNeed: false, needViewHideShowAfterLoading: nil, vc: self, isTokenNeeded: true, progressValue: { (progressValue) in
                progress.progress = Float(progressValue)
                alert.message = "\(Int(progressValue*100))%"
            }, isErrorAlertNeeded: true,errorBlock : {alert.dismiss(animated: true)}, actionErrorOrSuccess: { (isSuccess, message) in
                
            }, fromLoginPageCallBack: nil) { [weak self] (dict, error) in
                alert.dismiss(animated: true)
                if error == nil{
                    self?.getUserImages()
                    self?.showSingleButtonWithMessage(title: "Success", message: "Your photo has been uploaded successfully.", buttonName: "Okay")
                }
            }
        }
    }
    
}


extension ProfilePhotoMediaVC : EasyImagePickerDelegate{
    
    
    func didSelect(image: UIImage?, video: URL?, fileName: String?) {
        if let img = image{
            uploadPhoto(with: img)
        }else if let url = video{
            videoUrl = url
            uploadVideo()
        }
    }
    
}

class ProfilePhotoCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgProfilePhoto : UIImageViewX!
    
    //Button selected means have a photo
    @IBOutlet weak var btnDeleteOrAdd : UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


extension ProfilePhotoMediaVC : RangeSeekSliderDelegate{
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue: CGFloat) -> String? {
        return "\(Int(stringForMaxValue)) km"
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return "\(Int(minValue)) km"
    }
    
}
