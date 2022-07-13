//
//  SwipeCardsVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 07/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit
import CoreLocation

class SwipeCardsVC: UIViewController {
    
    @IBOutlet weak var swipeableView : ZLSwipeableView!
    @IBOutlet weak var viewForRipple : UIView!
    @IBOutlet weak var stackButtons : UIStackView!
    
    private var timer : Timer?
    
    private var userDataList : SwipeCardsBaseModel?{
        didSet{
            var users = userDataList?.result?.user ?? [UserDataModel]()
            if users.count > 0{
                stackButtons.isHidden = false
            }else{
                stackButtons.isHidden = true
            }
            if users.count > 9{
                showedList = Array((users)[...9])
                users = users.enumerated().filter({!Array(0...9).contains($0.offset)}).map({$0.element})
            }else{
                showedList = users
                users.removeAll()
            }
        }
    }
    
    private var showedList = [UserDataModel](){
        didSet{
            if showedList.count>0{
                self.setUpSwipeCards(with: showedList.count)
            }
        }
    }
    private var coordinate : CLLocationCoordinate2D?{
        didSet{
            saveLatLong()
        }
    }
    private var locationManager : CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manageSwipe()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        rippleAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationPermissionCheck()
        stackButtons.isHidden = true
        var data = [UserDataModel]()
        [1...9].forEach { _ in
            data.append(UserDataModel(dictionary: NSDictionary())!)
        }
        let result = SwipeCardsResult(dictionary: NSDictionary())
        let userDataList = SwipeCardsBaseModel(dictionary: NSDictionary())
        userDataList?.result = result
        userDataList?.result?.user = data
        self.userDataList = userDataList
//        checkData()
    }
    
    private func getUsers(){
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.get_all_user_list, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            self.userDataList = SwipeCardsBaseModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
        }
    }
    
    private func rippleAnimation(){
        self.viewForRipple.addRippleAnimation(color: CommonColor.ButtonGradientFirst)
        timer = Timer.scheduledTimer(withTimeInterval: 3.1, repeats: true) { (timer) in
            self.viewForRipple.removeRippleAnimation()
            self.viewForRipple.addRippleAnimation(color: CommonColor.ButtonGradientFirst)
        }
    }
    
    private func saveLatLong(){
        let param = ["latitude" : coordinate?.latitude.description ?? "",
                     "longtitude" : coordinate?.longitude.description ?? ""]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.edit_profile, isTokenNeeded: true, isErrorAlertNeeded: false, isSuccessAlertNeeded: false, actionErrorOrSuccess: { (succ, str) in }, fromLoginPageCallBack: nil) { _ in }
    }
    
    private func locationPermissionCheck(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showTwoButtonAlertWithTwoAction(title: CommonMessages.locationPermissionTitle, message: CommonMessages.locationPermissionMessage, buttonTitleLeft: CommonMessages.openSettings, buttonTitleRight: CommonMessages.cancel, completionHandlerLeft: {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(url)
            }, completionHandlerRight: {
                self.navigationController?.popViewController(animated: true)
            })
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            showTwoButtonAlertWithTwoAction(title: CommonMessages.locationPermissionTitle, message: CommonMessages.locationPermissionMessage, buttonTitleLeft: CommonMessages.openSettings, buttonTitleRight: CommonMessages.cancel, completionHandlerLeft: {
                guard let url = URL(string:UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(url)
            }, completionHandlerRight: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    private func checkData(){
        if !CommonUserDefaults.accessInstance.hasAllUserData(){
            let nav = Helper.getVcObject(vcName: .ProfileNavigationController, StoryBoardName: .Profile) as! ProfileNavigationController
            nav.needToEdit = true
            nav.modalPresentationStyle = .overCurrentContext
            nav.modalTransitionStyle = .coverVertical
            self.present(nav, animated: true, completion: nil)
        }else{
            getUsers()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    private func manageSwipe(){
        
        self.swipeableView.allowedDirection = [.Left,.Right]
        
        swipeableView.didSwipe = { view, direction, vector in
            if direction == .Right{
                self.swipeUserService(with: self.showedList.last?.id ?? "", isLike: true, user: self.showedList.last)
                //self.view.makeToast("Swipe right")
            }else{
                self.swipeUserService(with: self.showedList.last?.id ?? "", isLike: false, user: self.showedList.last)
                //self.view.makeToast("Swipe left")
            }
            
        }
        
        swipeableView.swiping = { view, loc , translate in
            guard let view = view as? CardContainerView else {return}
            if translate.x > 0{
                view.viewForLike.alpha = abs(translate.y) > 30 ? 1 : abs(translate.y) / 30
                view.viewForSkip.alpha = 0
            }else if translate.x < 0{
                view.viewForSkip.alpha = abs(translate.y) > 30 ? 1 : abs(translate.y) / 30
                view.viewForLike.alpha = 0
            }
            print("hellllooo",translate.x)
        }
        
        swipeableView.didEnd = { view, loc in
            guard let view = view as? CardContainerView else {return}
            view.viewForLike.alpha = 0
            view.viewForSkip.alpha = 0
        }
        
    }
    
    private func swipeUserService(with user_id: String, isLike : Bool, user : UserDataModel?){
        let param = ["to_id": user_id,
                     "like_status": isLike ? "Y" : "N"]
        APIReqeustManager.sharedInstance.serviceCall(param: param, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.swap_user, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: { _,_ in
        }, fromLoginPageCallBack: nil) { (resp) in
            if resp.error != nil{
                if let data = user{
                    
                }
            }
        }
    }
    
    //Set cards and data into container
    private func setUpSwipeCards(with : Int){
        self.swipeableView.numberOfActiveView = UInt(with)
        swipeableView.nextView = {
            return self.nextCardView()
        }
        manageCardView()
    }
    
    @objc private func btnTapped(){
        let data = showedList.first
        let vc = Helper.getVcObject(vcName: .SwipeCardsDetailsVC, StoryBoardName: .Main) as! SwipeCardsDetailsVC
        vc.userData = data
        vc.isLike = { [weak self] like in
            self?.swipeableView.swipeTopView(inDirection: like ? .Right : .Left)
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    private func manageCardView(){
        for i in (0..<swipeableView.activeViews().count){
            let viewIt = swipeableView.activeViews()[i] as? CardContainerView
            viewIt?.backgroundColor = .darkGray
            viewIt?.isUserInteractionEnabled = false
            let data = showedList[i]
            viewIt?.imgProfile.getImage(withUrl: (CommonUrl.profileImageURL)+(data.get_user_file?.first?.file_name ?? ""), placeHolder: CommonImage.placeholder, imgContentMode: .scaleAspectFill, imgContentModeOfPlaceHolder: .scaleAspectFit)
            if let distance = data.distance{
                viewIt?.lblFarAwayTop.text = "\(distance) km"
            }else{
                viewIt?.lblFarAwayTop.text = "Near you"
            }
            viewIt?.lblDescriptions.text = data.about ?? "Just like you. Love fun, break and travel."
            viewIt?.btnForWholeCard.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
            viewIt?.lblNameAndAge.text = [data.nick_name ?? "",data.age ?? ""].filter({$0 != ""}).joined(separator: " , ")
            if i == 0{
                viewIt?.isUserInteractionEnabled = true
                viewIt?.btnInfo.addTarget(self, action: #selector(btnInfo), for: .touchUpInside)
                viewIt?.addTapGestureRecognizer(action: { [weak self] in
                    self?.openSwipeDetails()
                })
            }
        }
    }
    
    private func openSwipeDetails(){
        let detailsVC = Helper.getVcObject(vcName: .SwipeCardsDetailsVC, StoryBoardName: .Main) as! SwipeCardsDetailsVC
        detailsVC.modalTransitionStyle = .crossDissolve
        detailsVC.modalPresentationStyle = .overCurrentContext
        self.present(detailsVC, animated: true, completion: nil)
    }
    
    @objc private func btnInfo(){
        self.view.makeToast("Info Clicked")
    }
    
    @IBAction func btnLike(_ from : UIButton){
        swipeableView.swipeTopView(inDirection: .Right)
    }
    
    @IBAction func btnDislike(_ from : UIButton){
        swipeableView.swipeTopView(inDirection: .Left)
    }
    
    // MARK: Load next card
    func nextCardView() -> UIView? {
        let cardView = Bundle.main.loadNibNamed("CardContainer", owner: self, options: nil)?.first! as! CardContainerView
        cardView.bounds = swipeableView.bounds
        return cardView
    }
    
}


extension SwipeCardsVC : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermissionCheck()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        coordinate = currentLocation.coordinate
        manager.stopUpdatingLocation()
    }
    
}
