//
//  AuthNavigationController.swift
//  Sama Contact Lens
//
//  Created by Convergent Infoware on 09/10/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit


class AuthNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
}

