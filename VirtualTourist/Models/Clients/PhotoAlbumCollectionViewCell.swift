//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/16/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        }
    }
}
