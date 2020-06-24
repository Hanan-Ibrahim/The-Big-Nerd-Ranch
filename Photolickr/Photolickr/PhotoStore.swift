//
//  PhotoStore.swift
//  Photolickr
//
//  Created by Hanoudi on 5/8/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//
//  PhotoStore will be responsible for initiating web service requests

import CoreData
import UIKit

// Represents results of downloading the image
enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

// If json data has array of photos -> success
enum PhotoResult {
    case success([Photo])
    case failure(Error)
}


class PhotoStore {
    let imageStore = ImageStore()
    
    let persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photolickr")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up the Core Data (\(error)).")
            }
        }
        return container
    }()
    // creates a session
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // to create URLRequest to connect to api.flickr.com
    // and asks for list interesting photos
    // then use URLSession to create URLSessionDataTask to
    // transfer this request to server
    // completion clousre because fetching data d=from sever is async process
    func fetchInterestingPhotos(completion: @escaping (PhotoResult) -> Void) {
        
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            var result = self.processPhotosRequest(data: data, error: error)
            
            if case .success = result {
                do {
                    try self.persistantContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        // for it is always created in suspended state
        task.resume()
    }
    func fetchRecentPhotos(completion: @escaping (PhotoResult) -> Void) {
        
        let url = FlickrAPI.recentPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request){
            (data, response, error) -> Void in
            var result = self.processPhotosRequest(data: data, error: error)
            
            if case .success = result {
                do {
                    try self.persistantContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        // for it is always created in suspended state
        task.resume()
    }
    
    // method to download image data, completion clousre will return an instance
    // of ImageResult
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        // save the images using imageStore
        // next time it will be loaded from file system if it is not currently in memory
        // this is for cellular data usage as well
        // unwrap optional NSURL and bridge instance to a URL instance
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have photoID")
        }
        if let image = imageStore.imageForKey(key: photoKey){
        OperationQueue.main.addOperation {
            completion(.success(image))
            }
            return
        }
        
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL")
        }
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request){
            (data, response, error)  -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image: image, forkey: photoKey)
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    
    // To process the JSON data returned from the web service request
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotoResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlickrAPI.photos(fromJSON: jsonData, into: persistantContainer.viewContext)
    }
    
    // To process data from web service request into an image, if possible
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
        let imageData = data,
        let image = UIImage(data: imageData) else {
            //Couldn't create an image
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        return .success(image)
    }
    
    func fetchAllPhotos(completion: @escaping (PhotoResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistantContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion (.failure(error))
            }
        }
    }
}
