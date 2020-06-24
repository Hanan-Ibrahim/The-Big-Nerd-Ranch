//
//  PhotoDataSource.swift
//  Photolickr
//
//  Created by Hanoudi on 5/9/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//
//  This will be the abstract of collection view data source

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    var photos = [Photo]()
    //var shownPhotos = [Photo]()
    //var allPhotos = [Photo]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PhotoCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhotoCollectionViewCell
        /*
        let photo = shownPhotos[indexPath.row]
        cell.updateWithImage(photo: photo)*/
        return cell
    }
    
}
