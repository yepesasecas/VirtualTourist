//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/13/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLongPressGesture()
        setupFetchedResultsController()
        loadPins()
    }

    // MARK: - Pin methods
    
    func loadPins() {
        
        guard let pins = fetchedResultsController.fetchedObjects else {
            print("no pins to load")
            return
        }
        
        pins.forEach() { pin in
            addAnnotation(coordinates: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
    }
    
    func addPin(coordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        try? dataController.viewContext.save()
    }
    
    // MARK: - Map View
    
    func addAnnotation(coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: - Long Press Gesture
    
    func addLongPressGesture() {
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
            addAnnotation(coordinates: coordinates)
            addPin(coordinates: coordinates)
            
        }
    }
}

extension TravelLocationMapViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TravelLocationMapViewController(70): TODO")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("TravelLocationMapViewController(74): TODO")
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("TravelLocationMapViewController(79): TODO")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("TravelLocationMapViewController(83): TODO")
    }

}
