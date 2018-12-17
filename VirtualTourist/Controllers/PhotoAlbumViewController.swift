//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/15/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin:Pin!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.debugDescription)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMap()
        setCollectionLayout()
        setupFetchedResultsController()
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhotos()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
        fetchedResultsController.fetchedObjects?.forEach() { photo in
            dataController.viewContext.delete(photo)
            do {
                try dataController.viewContext.save()
            } catch {
                print("unable to delete photo. \(error.localizedDescription)")
            }
        }
        self.collectionView.reloadData()
        loadPhotos()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.image = UIImage(named: "img-placeholder")
        
        let pin = fetchedResultsController.fetchedObjects![indexPath.row]
        if let data = pin.image {
            cell.imageView.image = UIImage(data: data)
        }
        
        return cell
    }
    
    // MARK: - Collection Layout
    
    func setCollectionLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK: - loaders
    
    func loadMap() {
        mapView.region.center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        mapView.addAnnotation(annotation)
    }
    
    func loadPhotos() {
        let flickrClient = Flickr.sharedInstance()
        flickrClient.getPhotos(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)) { (success, photos, error) in
            print("flickr images fetched : \(photos.count)")
            photos.forEach() { photo_url in
                let photo = Photo(context: self.dataController.viewContext)
                let url = URL(string: photo_url as! String)
                let data = try? Data(contentsOf: url!)
                photo.image = data
                photo.pin = self.pin
                do {
                    try self.dataController.viewContext.save()
                    print("image saved")
                } catch  {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}

extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("fetched objects count: \(fetchedResultsController.fetchedObjects!.count)")
            self.collectionView?.insertItems(at: [newIndexPath!])
            break
            
        case .delete:
            self.collectionView?.deleteItems(at: [indexPath!])
            break
        
        case .update:
            self.collectionView?.reloadItems(at: [indexPath!])
            break
            
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("PhotoAlbumViewController(127): TODO")
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("PhotoAlbumViewController(132): TODO")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("PhotoAlbumViewController(136): TODO")
    }
    
}
