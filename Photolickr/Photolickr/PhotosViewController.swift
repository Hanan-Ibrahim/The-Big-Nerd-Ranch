//
//  PhotosViewController.swift
//  Photolickr
//
//  Created by Hanoudi on 5/8/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    // Delegate of collection View to manage user interaction
    @IBOutlet var photosCollectionView: UICollectionView!
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    var store: PhotoStore!
    var photoDataSource = PhotoDataSource()

    

    @IBAction func choice(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            searchInterestingPhotos()
        case 1:
            searchRecentPhotos()
        default:
            break
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = photoDataSource
        updateDataSource()
        self.automaticallyAdjustsScrollViewInsets = false

           
    }
    
    
    func searchInterestingPhotos(){
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            self.updateDataSource()
        }
    }
    func searchRecentPhotos(){
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            
            self.updateDataSource()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
        
        // download image data
        store.fetchImage(for: photo) {(result) -> Void in
            // The index path for photo might have changed between the time the request
            // started and finished, so find the most recent index path
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            // When request is complete,  update the cell if its still visible
            if let cell = self.photosCollectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = photosCollectionView.indexPathsForSelectedItems?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destination as! PhotoDetailsViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (photosResult) in
            
            switch photosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.photosCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
}


extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.size.width
        let numberOfItemsPerRow: CGFloat = 4
        let itemWidth = collectionViewWidth / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        photosCollectionView.reloadData()
    }
}

