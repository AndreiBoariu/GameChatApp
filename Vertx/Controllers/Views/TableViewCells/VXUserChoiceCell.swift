//
//  VXUserChoiceCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/3/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

class VXUserChoiceCell: UITableViewCell {
    
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var lblOptionName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
