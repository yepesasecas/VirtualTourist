//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/11/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkIfFirstLaunch()
        dataController.load()
        
        let travelLocationMapViewController = getTravelLocationMapViewController()
        travelLocationMapViewController.dataController = dataController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
        saveTravelLocationMap()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveViewContext()
        saveTravelLocationMap()
    }
    
    // MARK: - Helpers
    
    func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set(false, forKey: "hasMapRegion")
            UserDefaults.standard.synchronize()
        }
    }
    
    func saveTravelLocationMap() {
        let travelLocationMapViewController = getTravelLocationMapViewController()
        let mapRegion = MapRegion(region: travelLocationMapViewController.mapView.region)
        mapRegion.save()
    }
    
    func getTravelLocationMapViewController() -> TravelLocationMapViewController {
        let navController = window?.rootViewController as! UINavigationController
        return navController.topViewController as! TravelLocationMapViewController
    }
    
    // MARK: - Core Data stack
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

