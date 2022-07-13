//
//  MainNavigationController.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 07/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    //enum value set as per tab tag
    enum MenuType : Int {
        case user = 0
        case charity = 1
        case home = 2
        case chats = 3
    }
    
    public var selectedMenuType : MenuType = .home {
        didSet{
            setUpTab()
        }
    }
    
    public var navTitle : String = "Just Afghans"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setUpTab()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //Set up view for top tab 
    private func setUpTab(){
        DispatchQueue.main.async {
            var tab : TopTabView{
                if let v = self.view.subviews.first(where: {$0 is TopTabView}) as? TopTabView{
                    return v
                }else{
                    let tabbar = Bundle.main.loadNibNamed("TopTabView", owner: self, options: nil)?.first! as! TopTabView
                    self.view.addSubview(tabbar)
                    return tabbar
                }
            }
            tab.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.view.addSubview(tab)
            tab.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(item: tab, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: tab, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: tab, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            tab.heightAnchor.constraint(equalToConstant: 60 + self.view.safeAreaInsets.top).isActive = true
            tab.imgCollection.forEach({$0.tintColor = $0.tag == self.selectedMenuType.rawValue ? CommonColor.ButtonGradientFirst : .lightGray})
            [tab.btnUser,tab.btnCharity,tab.btnHome,tab.btnChat].forEach({$0?.addTarget(self, action: #selector(self.btnTabTap), for: .touchUpInside)})
            self.view.addConstraints([top,leading,trailing])
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //Set up view for navition bar
    private func setUpNavigationBar(){
        DispatchQueue.main.async {
            var navbar : MainTopBar{
                if let v = self.view.subviews.first(where: {$0 is MainTopBar}) as? MainTopBar{
                    return v
                }else{
                    let nav = Bundle.main.loadNibNamed("MainTopBar", owner: self, options: nil)?.first! as! MainTopBar
                    self.view.addSubview(nav)
                    return nav
                }
            }
            navbar.lblEditProfile.text = self.navTitle
            navbar.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            navbar.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(item: navbar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: navbar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: navbar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            navbar.heightAnchor.constraint(equalToConstant: 60 + self.view.safeAreaInsets.top).isActive = true
            navbar.btnBack.addTarget(self, action: #selector(self.btnClickBack), for: .touchUpInside)
            self.view.addConstraints([top,leading,trailing])
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func btnClickBack(_ from : UIButton){
        self.popViewController(animated: true)
    }
    
    @objc func btnTabTap(_ from : UIButton){
        updateTab(with: from.tag)
        switch from.tag {
        case 0:
            let user = Helper.getVcObject(vcName: .ProfileVC, StoryBoardName: .Profile) as! ProfileVC
            self.checkAndPushPop(user,navigationController: self)
            break
        case 1:
            let ads = Helper.getVcObject(vcName: .CurrentSubscriptionVC, StoryBoardName: .Main) as! CurrentSubscriptionVC
            self.checkAndPushPop(ads,navigationController: self)
            break
        case 2:
            let home = Helper.getVcObject(vcName: .SwipeCardsVC, StoryBoardName: .Main) as! SwipeCardsVC
            self.checkAndPushPop(home,navigationController: self)
            break
        case 3:
            let chat = Helper.getVcObject(vcName: .ChatListVC, StoryBoardName: .Chat) as! ChatListVC
            self.checkAndPushPop(chat,navigationController: self)
            break
        default:
            break
        }
    }
    
    private func updateTab(with : Int){
        guard let tab = self.view.subviews.filter({$0 is TopTabView}).first as? TopTabView else {return}
        tab.imgCollection.forEach({$0.tintColor = $0.tag == with ? CommonColor.ButtonGradientFirst : .lightGray})
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        switch viewController {
        case is ProfileVC:
            navigationController.view.subviews.filter({$0 is MainTopBar}).forEach({$0.removeFromSuperview()})
            selectedMenuType = .user
            break
        case is CurrentSubscriptionVC:
            navigationController.view.subviews.filter({$0 is MainTopBar}).forEach({$0.removeFromSuperview()})
            selectedMenuType = .charity
            break
        case is SwipeCardsVC:
            navigationController.view.subviews.filter({$0 is MainTopBar}).forEach({$0.removeFromSuperview()})
            selectedMenuType = .home
            break
        case is ChatListVC:
            navigationController.view.subviews.filter({$0 is MainTopBar}).forEach({$0.removeFromSuperview()})
            selectedMenuType = .chats
            break
        default:
            navigationController.view.subviews.filter({$0 is TopTabView}).forEach({$0.removeFromSuperview()})
            setUpNavigationBar()
            break
        }
    }
}
