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
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionBtn: UIBarButtonItem!
    
    var pin:Pin!
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var selectedCells: [IndexPath]! = []
    
    // MARK: - Lifecycle
    
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
        if hasSelectedCells() {
            deleteSelectedCells()
        } else {
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
        
        let photo = fetchedResultsController.object(at: indexPath)
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            cell.imageView.image = UIImage(named: "img-placeholder")
            downloadImage(imagePath: photo.url!) { imageData, errorString in
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: imageData)
                    }
                    photo.data = imageData
                    try? self.dataController.viewContext.save()
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCells.contains(indexPath) == false {
            selectedCells.append(indexPath)
        }
        btnAction()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedCells.firstIndex(of: indexPath) {
            selectedCells.remove(at: index)
        }
        btnAction()
    }
    
    // MARK: - Private
    
    func setCollectionLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.allowsMultipleSelection = true
    }
    
    func loadMap() {
        mapView.region.center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        mapView.addAnnotation(annotation)
    }
    
    func loadPhotos() {
        let flickrClient = Flickr.sharedInstance()
        flickrClient.getPhotos(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)) { (success, photos, error) in
            
            if success == false {
                print("unable to download images from Flick.")
                return
            }
            
            print("flickr images fetched : \(photos.count)")
            
            photos.forEach() { photo_url in
                let photo = Photo(context: self.dataController.viewContext)
                photo.url = URL(string: photo_url as! String)?.absoluteString
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
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.objectID)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    
    func hasSelectedCells() -> Bool {
        if selectedCells.count == 0 {
            return false
        }
        return true
    }
    
    func btnAction() {
        if hasSelectedCells() {
            actionBtn.title = "Delete selected items"
        }
        else {
            actionBtn.title = "New Collection"
        }
    }
    
    func deleteSelectedCells() {
        let photos = selectedCells.map() { fetchedResultsController.object(at: $0) }
        photos.forEach() { photo in
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
    }
}

// MARK: - Extensions

extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
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
