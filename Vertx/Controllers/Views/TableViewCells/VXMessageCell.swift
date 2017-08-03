//
//  VXMessageCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/5/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Async

protocol VXMessageCellDelegate: class {
    func vxMessageCell_didSelectProfileUser(_ curUser: User)
}

/// Cell used for chat in feed details screen
class VXMessageCell: UITableViewCell {
    
    weak var delegate : VXMessageCellDelegate?
    
    var currentUser: User?
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Action Methods
    @IBAction func btnProfileImage_Action() {
        if let curUser = currentUser {
            delegate?.vxMessageCell_didSelectProfileUser(curUser)
        }
    }
}
