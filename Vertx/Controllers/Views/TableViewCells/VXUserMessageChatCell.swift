//
//  VXUserMessageChatCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/9/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

class VXUserMessageChatCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUserMessage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
