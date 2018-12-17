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

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
        saveTravelLocationMap()
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

