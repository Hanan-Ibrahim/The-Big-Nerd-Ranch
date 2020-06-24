//
//  ImageStore.swift
//  Photolickr
//
//  Created by Hanoudi on 5/9/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//
//  This will be used for image caching

import UIKit
class ImageStore: NSObject {
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(image: UIImage, forkey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // Create full URL for image
        let imageURL = imageURLForKey(key: key)
        
        // Turn image into JPEG data
        // Save in PNG instead of JPEG UIImageJPEGRepresentation(image, 0.5)
        //- number is the compression quality for JPEG
        if let data = image.pngData() {
            //Write it to full URL
            // let _ = try? data.write(to: url, options[.atomic])
            do {
                try data.write(to: imageURL as URL, options: .atomic)
            } catch {
                print("Error writing image on disk \(error)")
            }
        }
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        }
        
        let imageURL = imageURLForKey(key: key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key) as NSURL
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let imageURL = imageURLForKey(key: key)
        do {
            try FileManager.default.removeItem(at: imageURL as URL)
        } catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }
}
