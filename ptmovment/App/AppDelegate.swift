//
//  AppDelegate.swift
//  ptmovment
//
//  Created by Bijan Mirfakhrai on 6/24/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Application Lifecycle
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save Core Data when app terminates
        CoreDataStack.shared.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save Core Data when app enters background
        CoreDataStack.shared.save()
    }
    
    // MARK: - Background Fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Sync pending data in background
        DataPersistenceService.shared.syncPendingData { success in
            completionHandler(success ? .newData : .failed)
        }
    }

    // MARK: - Core Data stack
    
    // Remove the old Core Data stack since we're using CoreDataStack.shared
    // If you need to access the persistent container from AppDelegate for any reason:
    var persistentContainer: NSPersistentContainer {
        return CoreDataStack.shared.persistentContainer
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        CoreDataStack.shared.save()
    }
}
