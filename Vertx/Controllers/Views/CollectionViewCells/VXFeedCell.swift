//
//  VXFeedCell.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Kingfisher

class VXFeedCell: UICollectionViewCell {
    
    @IBOutlet weak var lblFeedName: UILabel!
    @IBOutlet weak var lblFeedType: UILabel!
    @IBOutlet weak var imgFeed: UIImageView!
    @IBOutlet weak var imgPlatform : UIImageView!
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.layer.cornerRadius = 5.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setFeedImageFromUrl(_ urlImage: URL!) {
        imgFeed.kf.indicatorType = .activity
        //imgFeed.
        
        //imgFeed.kf_showIndicatorWhenLoading = true
        //imgFeed.kf_setImageWithURL(urlImage)
    }
    
    func setPlatformImage(_ strPlatform: String) {
        //Options will be :["Xbox One", "PS4", "PC", "Wii U", "Xbox 360", "PS3", "Other"]
        
        let stringPlatform = strPlatform.removeWhitespace()
        imgPlatform.image = UIImage(named: stringPlatform.lowercased())
    }
}
