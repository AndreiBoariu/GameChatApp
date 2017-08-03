//
//  UIColor+Utils.swift
//  Vertx
//
//  Created by Boariu Andy on 8/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Spring

extension UIColor {
    class func color(_ red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: CGFloat(alpha))
    }
    
    class func vertxDarkBlue() -> UIColor {
        return UIColor(red:12.0/255, green:31.0/255, blue:46.0/255, alpha:1.0)
    }
    
    class func vertxDarkBlue(_ alpha: CGFloat) -> UIColor {
        return UIColor(red:12.0/255, green:31.0/255, blue:46.0/255, alpha:alpha)
    }
    
    class func vertxLightBlue() -> UIColor {
        return UIColor(red:22.0/255, green:91.0/255, blue:129.0/255, alpha:1.0)
    }
    
    class func vertxDarkOrange() -> UIColor {
        return UIColor(red:203.0/255, green:150.0/255, blue:80.0/255, alpha:1.0)
    }
    
    class func vertxLightOrange() -> UIColor {
        return UIColor(red:246.0/255, green:139.0/255, blue:31.0/255, alpha:1.0)
    }
    
    class func vertxLightestOrange() -> UIColor {
        return UIColor(red:235.0/255, green:195.0/255, blue:97.0/255, alpha:1.0)
    }
    
    class func vertxRedMiddle() -> UIColor {
        return UIColor(hex: "#C5392B")
    }
    
    class func vertxDarkBrown() -> UIColor {
        return UIColor(red:33.0/255, green:31.0/255, blue:34.0/255, alpha:1.0)
    }
}

extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
