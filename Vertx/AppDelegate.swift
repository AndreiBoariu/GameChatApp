//
//  AppDelegate.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var defaults = UserDefaults.standard
    
    /// Store full info about logged in user
    var curUser: User?
    
    /// Store full info about selected user in his profile screen. It will be nil if VXUserProfileVC not accessed
    var selectedUser: User?
    
    var locationManager: LocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //=>    Init Firebase sdk
        FIRApp.configure()
        
        //=>    Customize progress hud
        setActivityIndicator()
        
        //=>    Init Fabric and Crashlitycs
        Fabric.with([Crashlytics.self])
        
        //=>    Enable track location
        startLocationTracking()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Custom Methods
    
    func setActivityIndicator() {
        let configuration: KVNProgressConfiguration = KVNProgressConfiguration()
        
        configuration.circleStrokeForegroundColor = UIColor.vertxLightOrange()
        configuration.statusColor = UIColor.vertxDarkBlue()
        configuration.successColor = UIColor.vertxLightOrange()
        configuration.errorColor = UIColor.vertxDarkBlue()
        configuration.minimumErrorDisplayTime = 3
        configuration.minimumSuccessDisplayTime = 2
        configuration.minimumDisplayTime = 1.0
        configuration.circleSize = 80.0
        configuration.lineWidth = 2.0
        configuration.isFullScreen = false
        KVNProgress.setConfiguration(configuration)
    }
    
    // MARK: - CLLocation Methods
    func startLocationTracking() {
        if locationManager == nil {
            locationManager     = LocationManager()
            locationManager!.initLocationManager()
        }
    }
}

// MARK: - Convenience Constructors

let appDelegate = UIApplication.shared.delegate as! AppDelegate

// MARK: - UIApplication Extension Methods
extension UIApplication {
    
    class func appVersion() -> String? {
        if let strAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return strAppVersion
        }
        
        return nil
    }
    
    class func appBuild() -> String? {
        if let strAppBuild = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            return strAppBuild
        }
        
        return nil
    }
    
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(String(describing: version))" : "v\(version)(\(build))"
    }
}

extension UIViewController {
    var isViewTopOnStack: Bool {
        return self.isViewLoaded && view.window != nil
    }
}

