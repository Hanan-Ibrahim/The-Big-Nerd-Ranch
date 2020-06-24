//
//  FlickrAPI.swift
//  Photolickr
//
//  Created by Hanoudi on 5/8/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import Foundation
import CoreData

// Use of enums to specify endpoints 
enum Method: String{
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
    
}

// To represent possible errors for the FlickrAPI
enum FlickrError: Error {
    case invalidJSONData
}

// Will contain all knowledge specific to the Flickr API
struct FlickrAPI {
    // control access as private
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    // to convert dateTaken into instance of Data=e
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    static var recentPhotosURL: URL {
        return flickrURL(method: .recentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    // Takes two parameters
    // method to specify end points
    // params[:] for query items
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
        
        // Similar to the Codable Protocol Technique
        let baseParams = [
            "method" : method.rawValue,
            "format" : "json",
            "nojsoncallback" : "1",
            "api_key": apiKey
        ]
        
        for(key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    // parse a JSON dictionary into Photo instance
    private static func photo(fromJSON json: [String : Any], into context: NSManagedObjectContext) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                
                // Do not have enough info to construct Photo
                return nil
        }
    
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]!
        context.performAndWait {
            fetchedPhotos = try! context.fetch(fetchRequest)
        }
        if fetchedPhotos.count > 0 {
            return fetchedPhotos.first
        }
        
        
        var photo: Photo!
            context.performAndWait {
            photo = Photo(context: context)
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate as Date
        }
        
        return photo
    }
    // Takes instance of Data and converts it into basic foundation objects
    static func photos(fromJSON data: Data, into context: NSManagedObjectContext) -> PhotoResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // dig down through JSON data to get array of dictionaries
            // representating the indiviual photos
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else {
                    //The JSON structure doesnt match our expectations
                    return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            // update to parse dictionaries into Photo instances
            // then return as part of success enum
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON, into: context){
                    finalPhotos.append(photo)
                }
            }
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                // unable to parse photos or JSON format has changed
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }

}

