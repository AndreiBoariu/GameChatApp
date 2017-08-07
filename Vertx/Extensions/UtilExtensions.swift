//
//  UtilExtensions.swift
//  Vertx
//
//  Created by Boariu Andy on 9/3/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import UIKit


class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    var length : Int {
        return self.characters.count
    }
    
    func digitsOnly() -> String{
        let set             = CharacterSet(charactersIn: "+1234567890")
        
        let stringArray     = self.components(separatedBy: set.inverted)
        let newString       = stringArray.joined(separator: "")
        
        return newString
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

extension NSAttributedString {
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthWithConstrainedHeight(_ height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension Dictionary {
    
    var myDescription: String {
        get {
            var v = ""
            
            for (key, value) in self {
                v += ("\(key) = \(value)\n")
            }
            
            return v
        }
    }
    
    func prettyPrint(){
        for (key,value) in self {
            
            debugPrint("\(key) = \(value)")
        }
    }
}

extension UILabel
{
    /// Set text label like: "ImgPhoto Username Feeds"
    func addUserProfileImage(_ imgProfile: UIImage?, andUserName strUserName: String, andAppendText strAppendText: String?) {
        let attribWhite         = [NSForegroundColorAttributeName : UIColor.white]
        let attribOrange        = [NSForegroundColorAttributeName : UIColor.vertxLightestOrange()]
        
        let strLabelFullInfo = NSMutableAttributedString(string: "")
        
        //=>    Check image profile
        if let imgProfile = imgProfile {
            if let imgProfileCircle = imgProfile.circle {
                let attachment: NSTextAttachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: -10, width: self.height, height: self.height) // -10 is y bounds, just for center text horizontally
                attachment.image = imgProfileCircle
                
                let attachmentString = NSAttributedString(attachment: attachment)
                strLabelFullInfo.append(attachmentString)
            }
        }
        
        let strLabelText = NSAttributedString(string: " \(strUserName)", attributes: attribWhite)
        strLabelFullInfo.append(strLabelText)
        
        //=>    If there is append text, add it
        if let strAddText = strAppendText {
            let strFeedsText = NSAttributedString(string: " \(strAddText)", attributes: attribOrange)
            strLabelFullInfo.append(strFeedsText)
        }
        
        self.attributedText = strLabelFullInfo
    }
    
    /// Set label text like:  "Username • 6 hours ago"
    func setUserNameAndTimeForWrittenMessage(_ strUserName: String?, strTimeAgo:String?) {
        let attribWhite         = [NSForegroundColorAttributeName : UIColor.white]
        
        var attribGray          = [String: AnyObject]()
        if let font = UIFont.openSans_Regular_OfSize(14.0) {
            attribGray          = [NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName: font]
        }
        else {
            attribGray          = [NSForegroundColorAttributeName : UIColor.gray]
        }
        
        let attribOrange        = [NSForegroundColorAttributeName : UIColor.vertxLightestOrange()]
        let point               = " • "
        
        let strLabelFullInfo    = NSMutableAttributedString(string: "")
        
        if let strNameTemp = strUserName {
            let strName = NSAttributedString(string: " \(strNameTemp)", attributes: attribOrange)
            
            strLabelFullInfo.append(strName)
        }
        
        if let strTimeTemp = strTimeAgo {
            let strPoint = NSAttributedString(string: " \(point)", attributes: attribWhite)
            let strTimeAgoTemp = NSAttributedString(string: " \(VertxUtils.getWriteMessageTimeFromCreatedTime(strTimeTemp))", attributes: attribGray)
            
            strLabelFullInfo.append(strPoint)
            strLabelFullInfo.append(strTimeAgoTemp)
        }
        
        self.attributedText = strLabelFullInfo
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}

extension UIViewController {
    
    /** Resize a tableView header to according to the auto layout of its contents.
     - This method can resize a headerView according to changes in a dynamically set text label. Simply place this method inside viewDidLayoutSubviews.
     - To animate constrainsts, wrap a tableview.beginUpdates and .endUpdates, followed by a UIView.animateWithDuration block around constraint changes.
     */
    func sizeHeaderToFit(_ tableView: UITableView) {
        if let headerView = tableView.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            
            tableView.tableHeaderView = headerView
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

extension Array where Element: Equatable {
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

