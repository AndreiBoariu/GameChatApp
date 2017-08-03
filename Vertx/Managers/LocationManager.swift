//
//  LocationManager.swift
//  Vertx
//
//  Created by Boariu Andy on 8/27/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //=>     Create Singleton
    static let sharedInstance = LocationManager()
    
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var lastLocationFix = CLLocation()
    
    func initLocationManager() {
        seenError                           = false
        locationFixAchieved                 = false
        locationManager                     = CLLocationManager()
        locationManager.delegate            = self
        locationManager.desiredAccuracy     = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if (seenError == false) {
            seenError       = true
            print(error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            
            if let locationObj = locations.last {
                let coord           = locationObj.coordinate
                
                lastLocationFix     = locationObj
                
                print("Did Get Location: Lat \(coord.latitude) ----- Lon \(coord.longitude)")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.DidReceiveLocationFix), object: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case .restricted:
            locationStatus = "Restricted Access to location"
        
        case .denied:
            locationStatus = "User denied access to location"
        
        case .notDetermined:
            locationStatus = "Status not determined"
        
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        
        if (shouldIAllow == true) {
            // Start location services
            
            locationFixAchieved = false
            
            locationManager.startUpdatingLocation()
        }
        else {
            NSLog("Denied access: \(locationStatus)")
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.DidChangeLocationStatus), object: nil)
    }
}
