//
//  ProfileEthnicVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 31/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class ProfileEthnicVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtEthnic : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEthnic.delegate = self
        txtEthnic.addTarget(self, action: #selector(txtEditingChange), for: .editingChanged)
    }
    
    @objc func txtEditingChange(_ from : UITextField){
        
    }
    
    @IBAction func btnContinue(_ from : TransitionButton){
        let vc = Helper.getVcObject(vcName: .ProfileAcademicVC, StoryBoardName: .Profile) as! ProfileAcademicVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
