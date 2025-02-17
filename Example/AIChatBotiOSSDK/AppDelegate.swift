//
//  AppDelegate.swift
//  AIChatBotiOSSDK
//
//  Created by Frank Fu on 02/11/2025.
//  Copyright (c) 2025 Frank Fu. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initIQKeyboardManagerSwift()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        //let vc = RootViewController()
        //let vc = ChatViewController()
        let vc = TestRootViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }

    //MARK: Third SDK---IQKeyboardManager
    func initIQKeyboardManagerSwift(){
        IQKeyboardManager.shared.enable = true
    }

}

