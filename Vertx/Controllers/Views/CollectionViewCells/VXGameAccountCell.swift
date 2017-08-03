//
//  VXGameAccountCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/3/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

class VXGameAccountCell: UICollectionViewCell {
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var imgAccount: UIImageView!
    @IBOutlet weak var viewSeparator: UIView!
    
    func setImageAccountForOption(_ strOption: String) {
        imgAccount.image = UIImage(named: "\(strOption)_icon")
    }
}
