//
//  AppDelegate.swift
//  AQI
//
//  Created by Greg Alton on 6/26/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create a window that covers the screen
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create an instance for the root view controller and a navigation controller to wrap it in.
        let viewController = SplashViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let navigationController = window?.rootViewController as? UINavigationController {
            let splashViewController = SplashViewController()
            navigationController.setViewControllers([splashViewController], animated: false)
        }
    }

}

