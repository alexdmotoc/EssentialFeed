//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Alex Motoc on 17.10.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        
        #if DEBUG
        config.delegateClass = DebugSceneDelegate.self
        #endif
        
        return config
    }
}

