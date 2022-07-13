//
//  AdsVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 16/01/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

class AdsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView : UITableView!
    
    private var adsData = AdsListBaseModel(dictionary: NSDictionary()){
        didSet{
            if adsData?.my_ads?.count ?? 0 > 0 {
                tableView.restore()
            }else{
                tableView.setEmptyView(title: "No Ads", message: "Grow your business here. You can create a new ads and start collecting your customers.", messageImage: #imageLiteral(resourceName: "tab-logo"), titleColor: .black, messageColor: .darkGray, titleFont: .boldSystemFont(ofSize: 17), messageFont: .systemFont(ofSize: 16))
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.navigationController as? MainNavigationController)?.navTitle = "My Ads"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserAds()
    }
    
    private func getUserAds(){
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: true, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.ads_list, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            self.adsData = AdsListBaseModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
        }
    }
    
    @IBAction func btnAddAds(_ from : UIButton){
        let vc = Helper.getVcObject(vcName: .AddEditAdsVC, StoryBoardName: .Main) as! AddEditAdsVC
        self.checkAndPushPop(vc, navigationController: self.navigationController)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adsData?.my_ads?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdsTableCell", for: indexPath) as! AdsTableCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Choose Option", message: "What you want to do with your adsvertisement?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Active This", style: .default, handler: { (_) in
                
            }))
            alert.addAction(UIAlertAction(title: "Modify This", style: .default, handler: { (_) in
                let vc = Helper.getVcObject(vcName: .AddEditAdsVC, StoryBoardName: .Main) as! AddEditAdsVC
                vc.adsData = self.adsData?.my_ads?[indexPath.row]
                self.checkAndPushPop(vc, navigationController: self.navigationController)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        }
    }
    
}


class AdsTableCell: UITableViewCell {
    
    @IBOutlet weak var lblBusinessName : UILabel!
    @IBOutlet weak var lblBusinessPrice: UILabel!
    @IBOutlet weak var lblBusinessEmail : UILabel!
    @IBOutlet weak var lblBusinessNumber : UILabel!
    @IBOutlet weak var lblBusinessStartDate : UILabel!
    @IBOutlet weak var lblBusinessEndDate : UILabel!
    @IBOutlet weak var imgActiveOrNot : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
