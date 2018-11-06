//
//  AppDelegate.swift
//  Beamer
//
//  Created by OEA on 08/29/2018.
//  Copyright (c) 2018 OEA. All rights reserved.
//

import UIKit
import Beamer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var beamer: Beamer = Beamer(awsCredential: nil)

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = ViewController()
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        AppDelegate.beamer.application(application,
                                       handleEventsForBackgroundURLSession: identifier,
                                       completionHandler: completionHandler)
    }
}

