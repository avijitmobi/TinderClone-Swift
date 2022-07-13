//
//  ChatListVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 25/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ChatListVC: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    
    private var matchUserData : MatchListModel?{
        didSet{
            tableView.restore()
            if matchUserData?.match_list?.count ?? 0 == 0{
                tableView.setEmptyView(title: "No Messages", message: "Start swiping from today to match. You can purchase our premium package for faster match.", messageImage: CommonImage.emptyCards ?? #imageLiteral(resourceName: "tab-logo"), imageTint: CommonColor.ButtonGradientFirst, titleColor: .black, messageColor: .darkGray, titleFont: .boldSystemFont(ofSize: 17), messageFont: .systemFont(ofSize: 16))
            }
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        getMatches()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func getMatches(){
        APIReqeustManager.sharedInstance.serviceCall(param: nil, method: .post, loaderNeed: false, loadingButton: nil, needViewHideShowAfterLoading: nil, vc: self, url: CommonUrl.user_match_list, isTokenNeeded: true, isErrorAlertNeeded: true, isSuccessAlertNeeded: false, actionErrorOrSuccess: nil, fromLoginPageCallBack: nil) { (resp) in
            self.matchUserData = MatchListModel(dictionary: resp.dict as NSDictionary? ?? NSDictionary())
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


// Table View Protocols

extension ChatListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchUserData?.match_list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableCell", for: indexPath) as! ChatTableCell
        let data = matchUserData?.match_list?[indexPath.row]
        cell.lblName.text = data?.get_match_user?.nick_name ?? "No Name"
        cell.imgProfile.getImage(withUrl: (CommonUrl.profileImageURL)+(data?.get_match_user?.get_match_user_file?.first?.file_name ?? ""), placeHolder: CommonImage.placeholder, imgContentMode: .scaleAspectFill, imgContentModeOfPlaceHolder: .scaleAspectFill)
        cell.lblLastMessage.text = data?.get_match_user?.about ?? "Start chat now."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Helper.getVcObject(vcName: .ChatDetailsVC, StoryBoardName: .Chat) as! ChatDetailsVC
        let data = matchUserData?.match_list?[indexPath.row]
        vc.name = data?.get_match_user?.nick_name ?? "No Name"
        vc.first_id = data?.first_user_id
        vc.second_id = data?.second_user_id
        vc.image = data?.get_match_user?.get_match_user_file?.first?.file_name ?? ""
        vc.unique_id = data?.unique_identifier ?? ""
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .coverVertical
        nav.modalPresentationStyle = .overCurrentContext
        self.present(nav, animated: true, completion: nil)
    }
    
}

// Collection View Protocols


extension ChatListVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatProfileCollectionCell", for: indexPath) as! ChatProfileCollectionCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 5.0,left: 5.0,bottom: 5.0,right: 5.0)
    }
    
}


//Chat Table Cell

class ChatTableCell : UITableViewCell {
    
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblLastMessage : UILabel!
    @IBOutlet weak var lblLastDateTime : UILabel!
    @IBOutlet weak var lblNewMessageCount : UILabel!
    @IBOutlet weak var imgProfile : UIImageViewX!
    @IBOutlet weak var viewForNewMessageCount : UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}


// Chat Collection Cell


class ChatProfileCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imgProfile : UIImageViewX!
    @IBOutlet weak var viewForOnline : UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
