//
//  VXFeedProfileCell.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Async

protocol VXFeedProfileCellDelegate: class {
    func vxFeedProfileCell_didSelectProfileUser(_ curUser: User)
}

class VXFeedProfileCell: UICollectionViewCell {
    
    weak var delegate : VXFeedProfileCellDelegate?
    
    @IBOutlet weak var lblFeedName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgFeed: UIImageView!
    @IBOutlet weak var imgPlatform : UIImageView!
    @IBOutlet weak var imgUserProfile : UIImageView!
    
    var currentUser: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.layer.cornerRadius = 5.0        
    }
    
    func viewWillLayoutSubviews() {
        //=>    Keep text in top left corner
        lblFeedName.sizeToFit()
    }
    
    // MARK: - Custom Methods
    
    func setFeedImageFromUrl(_ urlImage: URL!) {
        imgFeed.kf.indicatorType = .activity
        
        imgFeed.kf.setImage(with: urlImage)
    }
    
    func setPlatformImage(_ strPlatform: String) {
        let stringPlatform = strPlatform.removeWhitespace()
        imgPlatform.image = UIImage(named: stringPlatform.lowercased())
    }
    
    // MARK: - Action Methods
    
    @IBAction func showUserProfile(_ sender: AnyObject) {
        if let curUser = currentUser {
            delegate?.vxFeedProfileCell_didSelectProfileUser(curUser)
        }
    }
}
