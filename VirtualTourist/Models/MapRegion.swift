//
//  MapRegion.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/14/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit

class MapRegion: NSObject {
    
    let region: MKCoordinateRegion!
    
    override init() {
        let mapCenterLatitude = UserDefaults.standard.double(forKey: "mapCenterLatitude")
        let mapCenterLongitude = UserDefaults.standard.double(forKey: "mapCenterLongitude")
        let mapSpanLatitudeDelta = UserDefaults.standard.double(forKey: "mapSpanLatitudeDelta")
        let mapSpanLongitudeDelta = UserDefaults.standard.double(forKey: "mapSpanLongitudeDelta")
        
        let center = CLLocationCoordinate2D(latitude: mapCenterLatitude, longitude: mapCenterLongitude)
        let span = MKCoordinateSpan(latitudeDelta: mapSpanLatitudeDelta, longitudeDelta: mapSpanLongitudeDelta)
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    init(region: MKCoordinateRegion) {
        self.region = region
    }
    
    func save() {
        UserDefaults.standard.set(region.center.latitude, forKey: "mapCenterLatitude")
        UserDefaults.standard.set(region.center.longitude, forKey: "mapCenterLongitude")
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: "mapSpanLatitudeDelta")
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: "mapSpanLongitudeDelta")
        UserDefaults.standard.set(true, forKey: "hasMapRegion")
        print("save MapRegion")
    }
    
    func hasMapRegion() -> Bool {
         return UserDefaults.standard.bool(forKey: "hasMapRegion")
    }
}
