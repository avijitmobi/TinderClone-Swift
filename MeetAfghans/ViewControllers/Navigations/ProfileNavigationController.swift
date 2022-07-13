//
//  ProfileNavigationController.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 25/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit


class ProfileNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    public var progress : CGFloat = 0.1{
        didSet{
            updateProgress()
        }
    }
    
    public var needToEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.setUpTab()
            self.progress = 0.1
        }
        
    }
    
    //Update progress
    private func updateProgress(){
        guard let nib = self.view.subviews.filter({$0 is TopProfileView}).first as? TopProfileView else {return}
        let mainWidth = nib.viewBarBackground.bounds.width
        if progress > 1{
            nib.progressWidthConstraint.constant = mainWidth
            nib.lblCompletedSatatus.text = "100% Completed"
        }else if progress < 0{
            nib.lblCompletedSatatus.text = "0% Completed"
            nib.progressWidthConstraint.constant = 0
        }else{
            nib.lblCompletedSatatus.text = "\(Int(progress*100))% Completed"
            nib.progressWidthConstraint.constant = mainWidth * progress
        }
        UIView.animate(withDuration: 0.4) {
            nib.layoutIfNeeded()
        }
    }
    
    //Set up view for top tab
    private func setUpTab(){
        let nib = Bundle.main.loadNibNamed("TopProfileView", owner: self, options: nil)?.first! as! TopProfileView
        guard !self.view.subviews.contains(nib) else {return}
        nib.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(nib)
        nib.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: nib, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: nib, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: nib, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        nib.btnBack.addTarget(self, action: #selector(self.btnBack), for: .touchUpInside)
        nib.heightAnchor.constraint(equalToConstant: nib.frame.height + self.view.safeAreaInsets.top).isActive = true
        self.view.addConstraints([top,leading,trailing])
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func btnBack(_ from : UIButton){
        if viewControllers.count == 1{
            let arr : [UserDefaultType] = [.userNickName,.userGender,.userDOB,.userProfession,.userEducation,.userMaritalStatus,.userHeight,.userPrefGender].filter({CommonUserDefaults.accessInstance.get(forType: $0) ?? "" == ""})
            if arr.count > 0{
                self.viewControllers.last?.view.makeToast("Please save all your information to find out partners.")
            }else{
                self.dismiss(animated: true) {
                    
                }
            }
            
        }else{
            self.popViewController(animated: true)
        }
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.progress = (CGFloat(self.viewControllers.count) / 9)
    }
}
