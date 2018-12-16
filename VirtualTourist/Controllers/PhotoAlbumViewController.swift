//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/15/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var coordinate:CLLocationCoordinate2D!
    
    var photos: [AnyObject?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMap()
        setCollectionLayout()
        loadPhotos()
    }
    
    // MARK: - Actions
    
    @IBAction func newCollection(_ sender: Any) {
    }
    
    // MARK: - UICollectionViewDelegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.imageView.image = UIImage(named: "img-placeholder")
        
        DispatchQueue.global().async {
            let photo_url = self.photos[indexPath.row]
            let url = URL(string: photo_url as! String)
            let data = try? Data(contentsOf: url!)
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
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
        mapView.region.center = coordinate
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
    }
    
    func loadPhotos() {
        let flickerClient = Flicker.sharedInstance()
        flickerClient.getPhotos(coordinate: coordinate) { (success, photos, error) in
            DispatchQueue.main.async {
                self.photos = photos
                self.collectionView.reloadData()
            }
        }
    }
}
