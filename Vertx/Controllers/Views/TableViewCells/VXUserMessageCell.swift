//
//  VXUserMessageCell.swift
//  Vertx
//
//  Created by Boariu Andy on 9/10/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import Async
import Kingfisher

class VXUserMessageCell: UITableViewCell {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!

    var message: ChatMessage? {
        didSet {
            setupNameAndProfileImage()
            
            //=>    Set message
            lblMessage.text = message?.messageText
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child(Constants.UserKeys.users).child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictUser = snapshot.value as? [String: AnyObject] {
                    
                    if let strUserName = dictUser[Constants.UserKeys.userFullName] as? String, let strCreatedDate = self.message?.createdDate {
                        self.lblUserName.setUserNameAndTimeForWrittenMessage(strUserName, strTimeAgo: strCreatedDate)
                    }
                    
                    if let strProfileURL = dictUser[Constants.UserKeys.userProfileURL] as? String, let urlProfileImage = URL(string: strProfileURL) {
                        self.setProfileImage(urlProfileImage)
                    }
                    else {
                        Async.main {
                            self.imgUserProfile.image = UIImage(named: "profile_icon")
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func setProfileImage(_ urlImage: URL!) {
        imgUserProfile.kf.setImage(with: urlImage, placeholder: UIImage(named: "no_profile"), options: [.transition(ImageTransition.fade(1))])
        { (image, error, cacheType, imageURL) in
            if let img = image {
                self.imgUserProfile.image = img.circle
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
