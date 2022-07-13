//
//  File.swift
//  MeetAfghans
//
//  Created by Convergent Infoware on 07/12/20.
//  Copyright © 2020 Convergent Infoware. All rights reserved.
//

import UIKit

class TopTabView : UIView{
    
    @IBOutlet weak var btnUser : UIButton!
    @IBOutlet weak var btnCharity : UIButton!
    @IBOutlet weak var btnHome : UIButton!
    @IBOutlet weak var btnChat : UIButton!
    
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgCharity : UIImageView!
    @IBOutlet weak var imgHome : UIImageView!
    @IBOutlet weak var imgChat : UIImageView!
    
    @IBOutlet var imgCollection : [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
