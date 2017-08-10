//
//  VXUserCell.swift
//  Vertx
//
//  Created by Boariu Andy on 8/27/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Async

class VXUserCell: UICollectionViewCell {
    
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblUserDistance: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgProfile : UIImageView!
    
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.layer.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setDistanceLabelTextInKm(_ dDistance: Double?) {
        if let  dUserDistance = dDistance {
            if dUserDistance == DBL_MAX {
                lblUserDistance.text = "no location set"
            }
            else {
//                let km = (dUserDistance / 1000.0).roundToPlaces(2)
//                lblUserDistance.text = "\(km) km"
            }
        }
    }
}
