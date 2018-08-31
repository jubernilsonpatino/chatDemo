//
//  UsersTableViewCell.swift
//  chatDemo
//
//  Created by Sundevs on 2/25/17.
//  Copyright © 2017 Sundevs. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var labEmail: UILabel!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
