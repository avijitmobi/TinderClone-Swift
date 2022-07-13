//
//  CurrentSubscriptionVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 05/03/21.
//  Copyright © 2021 Convergent Infoware. All rights reserved.
//

import UIKit

struct SubcriptionsData {
    var isFree : Bool = true
    var text : String?
}


class CurrentSubscriptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var btnPaidMember : TransitionButton!
    @IBOutlet weak var lblCurrentMemberStatus : UILabel!
    
    let arr = [SubcriptionsData(isFree: true, text: "You can find your preferble partner by your preference."),SubcriptionsData(isFree: true, text: "Limited swipe  features."),SubcriptionsData(isFree: true, text: "Limited Likes."),SubcriptionsData(isFree: false, text: "Unlimited profiles matches with your prefrences"),SubcriptionsData(isFree: false, text: "Unlimited swipes."),SubcriptionsData(isFree: true, text: "Unlimited likes.")]
    var finalArr : [[SubcriptionsData]] {
        var array = [[SubcriptionsData]]()
        array.append(arr.filter({$0.isFree == true}))
        array.append(arr.filter({$0.isFree == false}))
        return array
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    @IBAction func btnPaidOrRenewMembership(_ from : UIButton){
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "CurrentMembershipHeaderCell") as! CurrentMembershipHeaderCell
        if section == 0{
            header.lblHeader.text = "Your Benifits"
        }else{
            header.lblHeader.text = "Our Member Benifits"
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return finalArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentMembershipBenifitsCell", for: indexPath) as! CurrentMembershipBenifitsCell
        let data = finalArr[indexPath.section][indexPath.row]
        cell.lblBenifits.text = data.text
        cell.imgAvailableUnavailableBenifits.image = data.isFree == true ? CommonImage.tickMark : CommonImage.crossMark
        return cell
    }
    
}


class CurrentMembershipBenifitsCell : UITableViewCell {
    
    @IBOutlet weak var lblBenifits : UILabel!
    @IBOutlet weak var imgAvailableUnavailableBenifits : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}


class CurrentMembershipHeaderCell : UITableViewCell {
    
    @IBOutlet weak var lblHeader : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
