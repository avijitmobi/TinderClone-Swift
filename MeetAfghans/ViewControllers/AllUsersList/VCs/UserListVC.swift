//
//  UserListVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 25/02/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit


class UserListVC : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    enum UserListType : String{
        case like = "Like"
        case dislike = "Dislike"
        case blocks = "Block"
    }
    
    @IBOutlet weak var tableView : UITableView!
    
    private var likeUserData : LikedUserBaseModel?{
        didSet{
            tableView.restore()
            if likeUserData?.user_like_list?.count ?? 0 == 0{
                tableView.setEmptyView(title: "Empty \(userType.rawValue) List", message: "There is no user in this category. Please swap some user's profile and meet with new people.", messageImage: CommonImage.emptyCards ?? UIImage())
            }
            tableView.reloadData()
        }
    }
    public var userType : UserListType = .like
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
    }
    
    private func getUsers(){
        var url : String{
            if userType == .blocks{
                (self.navigationController as? MainNavigationController)?.navTitle = "Block List"
                return CommonUrl.user_block_list
            }else if userType == .dislike{
                (self.navigationController as? MainNavigationController)?.navTitle = "Dislike List"
                return CommonUrl.user_dislike_list
            }else if userType == .like{
                (self.navigationController as? MainNavigationController)?.navTitle = "Like List"
                return CommonUrl.user_like_list
            }else{
                return CommonUrl.get_all_user_list
            }
        }
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: url, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            self.likeUserData = LikedUserBaseModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeUserData?.user_like_list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        let data = likeUserData?.user_like_list?[indexPath.row].get_user
        cell.lblName.text = data?.nick_name
        cell.lblDetails.text = data?.about
        cell.imgUser.getImage(withUrl: (CommonUrl.profileImageURL)+(data?.get_user_file?.first?.file_name ?? ""), placeHolder: CommonImage.placeholder, imgContentMode: .scaleAspectFill, imgContentModeOfPlaceHolder: .scaleAspectFill)
        return cell
    }
    
}


