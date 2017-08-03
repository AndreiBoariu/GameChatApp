//
//  UIFont+Utils.swift
//  Vertx
//
//  Created by Boariu Andy on 8/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

extension UIFont {
    class func openSans_Bold_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-Bold", size: size)
    }
    
    class func openSans_BoldItalic_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-BoldItalic", size: size)
    }
    
    class func openSans_ExtraBold_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-ExtraBold", size: size)
    }
    
    class func openSans_ExtraBoldItalic_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-ExtraBoldItalic", size: size)
    }
    
    class func openSans_Italic_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-Italic", size: size)
    }
    
    class func openSans_Light_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-Light", size: size)
    }
    
    class func openSans_LightItalic_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-LightItalic", size: size)
    }
    
    class func openSans_Regular_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans", size: size)
    }
    
    class func openSans_SemiBold_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-Semibold", size: size)
    }
    
    class func openSans_SemiBoldItalic_OfSize(_ size: CGFloat) -> UIFont? {
        return UIFont(name: "OpenSans-SemiboldItalic", size: size)
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            debugPrint("------------------------------")
            debugPrint("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            debugPrint("Font Names = [\(names)]")
        }
    }
}
