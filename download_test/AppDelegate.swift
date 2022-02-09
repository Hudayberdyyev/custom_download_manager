//
//  AppDelegate.swift
//  download_test
//
//  Created by Ahmet on 09.02.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(#function)
        if #available(iOS 13.0, *) {
            
        } else {
            // Initialize window
            window = UIWindow(frame: UIScreen.main.bounds)
            
            window?.rootViewController = ViewController()
            
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        HLSData.restoreDownloadsTasks()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == K.FileStorage.DownloadsConfiguration.hlsIdentifier {
            
        }
    }

    // MARK: UISceneSession Lifecycle
    @available (iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available (iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

