//
//  AppDelegate.swift
//  iMusic
//
//  Created by rigo on 19/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            
            let trackListVC = TrackListView()
            window!.rootViewController = trackListVC
            window!.makeKeyAndVisible()
        }
        
        return true
    }
}

