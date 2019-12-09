//
//  AppDelegate.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsungwei on 7/11/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let LOGTAG = "[AppDelegate] "
    
    var window: UIWindow?
    var latestLocation: CLLocation?
    var locationMgr = CLLocationManager()
    var uiStyle: SearchUserInterfaceStyle = .light

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set global state for userInterfaceStyle
        if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
            uiStyle = .dark
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainView = MainViewController()
        self.window!.rootViewController = mainView
        self.window?.makeKeyAndVisible()
        setupLocationManager()
        return true
    }
    /**
     Set up location manager.
     */
    func setupLocationManager() {
        locationMgr.allowsBackgroundLocationUpdates = true
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
    }
}
// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latestLocation = locations.last != nil ? locations.last! : latestLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(self.LOGTAG) didFailWithError \(error)")
    }
}

enum SearchUserInterfaceStyle {
    case light
    case dark
}
