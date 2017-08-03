//
//  VertxUtils.swift
//  Vertx
//
//  Created by Boariu Andy on 8/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

open class VertxUtils {
    
    class func okCustomAlert(_ title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        return alert
    }
    
    class func okAlert(_ message: String?) -> UIAlertController {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        }))
        
        return alert
    }
    
    class func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    class func getStringDateFromDate(_ date: Date) -> String? {
        return date.string(format: .iso8601Auto)
    }
    
    class func getStringTimeFromDate(_ date: Date) -> String? {
        return date.string(custom: "HH:mm")
    }
    
    /// Function used to display feed time and date in format: 23:33 29/08/16
    class func getStringDateAndTimeFromCreatedStringDate(_ strDate: String) -> String? {
        //=>    Final string date should be in format:  23:33 29/08/16
        var strFinalDate = ""
        
        //=>    Convert string to NSDate format
        let date = getDateFromStringDate(strDate)
        strFinalDate += date.string(custom: "HH:mm") + " " + date.string(custom: "dd/MM/yy")
        
        return strFinalDate
    }
    
    /// Function used to display how many mins or hours ago was message written
    class func getWriteMessageTimeFromCreatedTime(_ strCreatedTime: String) -> String {
        let startDate = getDateFromStringDate(strCreatedTime)
        
        
        let timezone            = TimeZone(secondsFromGMT: 60 * 60)
        let region              = Region(tz: timezone!, cal: Calendar.current, loc: Locale.current)
        let date                = DateInRegion(absoluteDate: startDate, in: region)
        
        var options             = ComponentsFormatterOptions(
            allowedUnits: [.year, .month, .weekOfMonth, .day, .hour, .minute, .second],
            style: .abbreviated,
            zero: .default
        )
        
        options.maxUnitCount    = 1
        
        let now                 = DateInRegion(absoluteDate: Date(), in: region)
        let time                = try! now.timeComponents(toDate: date, options: options)
        
        return time
    }
    
//    class func getStringDateFromCreatedStringDate(strDate: String) -> String? {
//        let date = getDateFromStringDate(strDate)
//    }
    
    class func getDateFromStringDate(_ strDate: String) -> Date {
        return (strDate.date(format: .iso8601Auto)?.absoluteDate)!
    }

    class func sizeOfAttributeString(_ str: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        let size = str.boundingRect(with: CGSize(width: maxWidth, height: 1000), options:(NSStringDrawingOptions.usesLineFragmentOrigin), context:nil).size
        return size
    }
    
    class func imageFromText(_ text: String, font: UIFont, maxWidth: CGFloat, color:UIColor) -> UIImage {
        let paragraph               = NSMutableParagraphStyle()
        paragraph.lineBreakMode     = NSLineBreakMode.byWordWrapping
        paragraph.alignment         = .center
        
        let attributedString        = NSAttributedString(
            string: text,
            attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
        )
        
        //let size                    = sizeOfAttributeString(attributedString, maxWidth: 20)
        let offset                  = CGFloat(15)
        let size                    = CGSize(width: offset, height: offset)
        
        UIGraphicsBeginImageContextWithOptions(size, false , UIScreen.main.scale)
        let context                 = UIGraphicsGetCurrentContext()
        
        UIColor.red.setFill()
        context!.fill(CGRect(x: (maxWidth - offset)/2, y: (maxWidth - offset)/2, width: size.width, height: size.height))
        
        //attributedString.drawInRect(CGRectMake(0, 0, size.width, size.height))
        attributedString.draw(in: CGRect(x: (maxWidth - offset)/2, y: (maxWidth - offset)/2, width: size.width, height: size.height))
        let image                   = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    class func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    
    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    
    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}
