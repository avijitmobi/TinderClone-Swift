//
//  AddEditAdsVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 04/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit


class AddEditAdsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewPhotoMedia : UICollectionView!
    @IBOutlet weak var txtBusinessName : UITextField!
    @IBOutlet weak var txtPackageDuration : UITextField!
    @IBOutlet weak var txtCompany : UITextField!
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtUrl : UITextField!
    @IBOutlet weak var txtDescriptions : UITextView!
    @IBOutlet weak var txtPackagePrice : UITextField!
    @IBOutlet weak var heightCollectionViewPhotoMedia : NSLayoutConstraint!
    
    var image : UIImage?
    var video_url : URL?
    private var imagePicker : EasyImagePicker?
    var adsData = MyAdsList(dictionary: NSDictionary())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewPhotoMedia.reloadData()
        imagePicker = EasyImagePicker(presentationController: self, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtBusinessName.text = adsData?.business_name
        txtPackageDuration.text = "\(adsData?.package_duration ?? "1") Month(s)"
        txtPackagePrice.text = adsData?.package_price
        txtUrl.text = adsData?.url
        txtEmail.text = adsData?.email
        txtPhoneNumber.text = adsData?.mobile
        txtDescriptions.text = adsData?.description
        txtCompany.text = adsData?.company
        collectionViewPhotoMedia.reloadData()
    }
    
    @IBAction func btnPackageDurations(_ from : UIButton){
        showDropDown(with: (1...12).map({"\($0) Month(s)"}), from: from) { (title, index) in
            self.txtPackagePrice.text = title
        }
    }
    
    @IBAction func btnPackagePrice(_ from : UIButton){
        showDropDown(with: (50...500).map({$0/50 == 0}).map({"$\($0)"}), from: from) { (title, index) in
            self.txtPackagePrice.text = title
        }
    }
    
    @IBAction func btnUpload(_ from : UIButton){
        btnAddPhotoMedia(from: from)
    }
    
    func btnAddPhotoMedia(from : UIButton){
        showTwoButtonAlertWithTwoAction(title: "Choose Prefereable Option", buttonTitleLeft: "Choose Image", buttonTitleRight: "Choose Video") {
            self.imagePicker?.present(from: from, mediaType: .images, onViewController: self)
        } completionHandlerRight: {
            self.imagePicker?.present(from: from, mediaType: .video, onViewController: self)
        }
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        
        guard let businessName = self.txtBusinessName.text?.trim(), businessName != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .business_name))
        }
        
        guard let packageDuration = self.txtPackageDuration.text?.trim(), packageDuration != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .package_duration))
        }
        
        guard let packagePrice = self.txtPackagePrice.text?.trim(), packagePrice != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .packange_price))
        }
        
        guard let company = self.txtCompany.text?.trim(), company != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .company))
        }
        
        guard let url = self.txtUrl.text?.trim(), url != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .ads_url))
        }
        
        guard let phone = self.txtPhoneNumber.text?.trim(), phone.count >= 8 else{
            return self.view.makeToast(CommonMessages.validationError(of: .mobileNo))
        }
        
        guard let email = self.txtEmail.text?.trim(), email.isValidEmail() else{
            return self.view.makeToast(CommonMessages.validationError(of: .email))
        }
        
        guard let desc = self.txtDescriptions.text?.trim(), desc != "" else{
            return self.view.makeToast(CommonMessages.validationError(of: .ads_description))
        }
        
//        if self.image == nil && self.video_url == nil {
//            return self.view.makeToast(CommonMessages.validationError(of: .ads_photo))
//        }
        
        let param = ["business_name" : businessName,
                     "package_duration" : packageDuration.replacingOccurrences(of: " Month(s)", with: ""),
                     "company" : company,
                     "mobile" : phone,
                     "email" : email,
                     "url" : url,
                     "description" : desc,
                     "package_price" : packagePrice,
                     "status" : "I"]
        showProgressBarInAlert { (alert, progress) in
            APIReqeustManager.sharedInstance.uploadWithAlamofire(multipart: { (multiPartData) in
                if let url = self.video_url{
                    multiPartData.append(url, withName: "file_name")
                }
                if let img = self.image{
                    multiPartData.append(img.jpegData(compressionQuality: 1) ?? Data(), withName: "file_name", fileName: "image", mimeType: "image/jpeg")
                }
                param.forEach { (key,value) in
                    multiPartData.append(value.data(using: .utf8) ?? Data(), withName: key)
                }
            }, url: CommonUrl.add_ads, method: .post, loadingButton: nil, loaderNeed: false, needViewHideShowAfterLoading: nil, vc: self, isTokenNeeded: true, progressValue: { (progressValue) in
                progress.progress = Float(progressValue)
                alert.message = "\(Int(progressValue*100))%"
            }, isErrorAlertNeeded: true,errorBlock : {alert.dismiss(animated: true)}, actionErrorOrSuccess: { (isSuccess, message) in
                
            }, fromLoginPageCallBack: nil) { [weak self] (dict, error) in
                alert.dismiss(animated: true)
                if error == nil{
                    self?.showTwoButtonAlertWithTwoAction(title: "Success", buttonTitleLeft: "Contact To Activate", buttonTitleRight: "Done", completionHandlerLeft: {
                        self?.openInstagram(with: "avijitmobi")
                    }, completionHandlerRight: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCollectionCell", for: indexPath) as! ProfilePhotoCollectionCell
        if let img = self.image{
            cell.btnDeleteOrAdd.isSelected = true
            cell.imgProfilePhoto.image = img
        }else if let url = self.video_url{
            cell.btnDeleteOrAdd.isSelected = true
            cell.imgProfilePhoto.image = getThumbnailImage(forUrl : url)
        }else{
            cell.btnDeleteOrAdd.isSelected = false
            cell.imgProfilePhoto.image = nil
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfilePhotoCollectionCell{
            if cell.btnDeleteOrAdd.isSelected {
                let alert = UIAlertController(title: "Alert", message: "What you want to do with your media file?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (_) in
                    self.image = nil
                    self.video_url = nil
                    self.collectionViewPhotoMedia.reloadData()
                }))
                if let url = self.video_url{
                    alert.addAction(UIAlertAction(title: "View Video", style: .default, handler: { (_) in
                        self.playVideo(with: url)
                    }))
                }
                self.present(alert, animated: true, completion: nil)
            }else{
                btnAddPhotoMedia(from: cell.btnDeleteOrAdd)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.bounds.width
        let items : CGFloat = 3
        let minItemSpacing : CGFloat = 10
        let cellWidth = collectionWidth/items
        let cellHeight = cellWidth + (cellWidth*0.2)
        let count = CGFloat((collectionView.numberOfItems(inSection: 0))) < items ? CGFloat(1) : (CGFloat(collectionView.numberOfItems(inSection: 0))/items)
        heightCollectionViewPhotoMedia.constant = (cellHeight*count) + (count*minItemSpacing)
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}


extension AddEditAdsVC : EasyImagePickerDelegate {
    
    func didSelect(image: UIImage?, video: URL?, fileName: String?) {
        if let img = image{
            self.image = img
        }else if let url = video{
            self.video_url = url
        }
        collectionViewPhotoMedia.reloadData()
    }
    
}
