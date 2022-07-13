//
//  SplashScreenVC.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 04/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let splashVideo = Helper.getVcObject(vcName: .SplashVideoVC, StoryBoardName: .Main) as! SplashVideoVC
            self.checkAndPushPop(splashVideo, navigationController: self.navigationController)
        }
        // Do any additional setup after loading the view.
    }
    

}
