//
//  PhotoCollectionViewCell.swift
//  Photolickr
//
//  Created by Hanoudi on 5/9/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//
//  Custom class for Photo Cell

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    // display an activity indicator when cell is not displaying an image
    func update(with image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    // to reset the cell back to the image to spinning state
    override func awakeFromNib() {
        super.awakeFromNib()
        update(with: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(with: nil)
    }

}
