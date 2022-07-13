//
//  SwipeCardsDetailsVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 09/01/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class SwipeCardsDetailsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var lblNameWithAge : UILabel!
    @IBOutlet weak var lblDescriptions : UILabel!
    @IBOutlet weak var lblAwayKms : UILabel!
    @IBOutlet weak var lblEducationsOrHobby : UILabel!
    @IBOutlet weak var viewVerified : UIView!
    @IBOutlet weak var viewNearYou : UIView!
    @IBOutlet weak var viewEducationHobby : UIView!
    @IBOutlet weak var viewTagList : TagListView!
    
    var userData : UserDataModel?
    var isLike : ((Bool)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let distance = userData?.distance{
            lblAwayKms.text = "\(distance) km away"
        }else{
            lblAwayKms.text = "Just near you"
        }
        if let distance = userData?.college_school{
            lblEducationsOrHobby.text = distance
            viewEducationHobby.isHidden = false
        }else if let edu = userData?.level_of_education{
            lblEducationsOrHobby.text = edu
            viewEducationHobby.isHidden = false
        }else{
            lblEducationsOrHobby.text = ""
            viewEducationHobby.isHidden = true
        }
        if userData?.is_verified == "Y"{
            viewVerified.isHidden = false
        }else{
            viewVerified.isHidden = true
        }
        lblDescriptions.text = userData?.about
        loadTags()
    }
    
    private func loadTags(){
        let a = userData?.company ?? ""
        let b = userData?.job_title ?? ""
        let c = userData?.passion ?? ""
        let d = userData?.living ?? ""
        let e = userData?.gender ?? ""
        let f = userData?.marital_status ?? ""
        viewTagList.addTags([a,b,c,d,e,f].filter({$0 != ""}))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func btnBack(_ from : UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDislike(_ from : UIButton){
        self.dismiss(animated: true) {
            self.isLike?(false)
        }
    }
    
    @IBAction func btnLike(_ from : UIButton){
        self.dismiss(animated: true) {
            self.isLike?(true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = userData?.get_user_file?.count ?? 0
        return userData?.get_user_file?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserImagesCollectionCell", for: indexPath) as! UserImagesCollectionCell
        let data = userData?.get_user_file?[indexPath.row]
        cell.imgUser.getImage(withUrl: (CommonUrl.profileImageURL)+(data?.file_name ?? ""), placeHolder: CommonImage.placeholder, imgContentMode: .scaleAspectFit, imgContentModeOfPlaceHolder: .scaleToFill)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

}

extension SwipeCardsDetailsVC : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else {return}
        pageControl.currentPage = collectionView.indexPathsForVisibleItems.first?.row ?? 0
    }
    
}


class UserImagesCollectionCell : UICollectionViewCell{
    
    @IBOutlet weak var imgUser : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
