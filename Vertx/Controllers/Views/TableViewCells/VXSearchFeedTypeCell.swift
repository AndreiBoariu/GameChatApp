//
//  VXSearchFeedTypeCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

class VXSearchFeedTypeCell: UITableViewCell {

    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var lblFeedType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
