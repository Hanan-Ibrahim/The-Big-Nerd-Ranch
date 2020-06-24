//
//  PhotoDetailsViewController.swift
//  Photolickr
//
//  Created by Hanoudi on 5/9/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//
//  This is to show details of photo when selected on collection view

import UIKit

class PhotoDetailsViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
