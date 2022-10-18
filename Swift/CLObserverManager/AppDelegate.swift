//
//  AppDelegate.swift
//  CLObserverManager
//
//  Created by Chen JmoVxia on 2022/10/18.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let nav = UINavigationController(rootViewController: AViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}

