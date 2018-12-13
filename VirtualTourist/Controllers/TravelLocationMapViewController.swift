//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/13/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationMapViewController.handleLongPress(_:)))
        lpgr.delegate = self
        lpgr.minimumPressDuration = 1
        lpgr.delaysTouchesBegan = true
        mapView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        print(sender)
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            print(coordinates)
            
            self.mapView.addAnnotation(annotation)
        }
    }
}
