//
//  ChatListTableViewCell.swift
//  chatDemo
//
//  Created by Sundevs on 3/6/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var labDate: UILabel!
    @IBOutlet weak var labMessage: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var constraintWidthCameraIcon: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
