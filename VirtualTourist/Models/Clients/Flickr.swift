//
//  Flicker.swift
//  VirtualTourist
//
//  Created by Andres Yepes on 12/15/18.
//  Copyright © 2018 Andres Yepes. All rights reserved.
//

import UIKit
import MapKit

class Flickr: NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    func getPhotos(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ success: Bool, _ photos: [AnyObject?], _ error: String?)-> Void) -> Void {
        
        let parameters: [String: String] = [
            "format": "json",
            "nojsoncallback": "1",
            "lat": "\(coordinate.latitude)",
            "lon": "\(coordinate.longitude)",
            "api_key": "ceb80d2a2c3e898cefc084a838bd2d7e",
            "method": "flickr.photos.search"
        ]
        let request = createURLRequest(method: "GET", path: "/services/rest", parameters: parameters)
        print("Request: \(request.url!)")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(false, [], error.debugDescription)
                return
            }
            
            guard let data = data else {
                print("no data returned")
                completionHandler(false, [], "no data returned")
                return
            }
            
            var parsedData: AnyObject! = nil
            do{
                parsedData =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            }
            catch {
                print("unable to parse json \(String(data: data, encoding: .utf8)!)")
                completionHandler(false, [], "unable to parse json")
                return
            }
            
            guard let photos = parsedData?["photos"] as? AnyObject,
                let photo = photos["photo"] as? [AnyObject]  else {
                    print("no photos attribute present")
                    return
            }
            
            let photos_url = photo.map(){ photo in
                "https://farm\(photo["farm"]!!).staticflickr.com/\(photo["server"]!!)/\(photo["id"]!!)_\(photo["secret"]!!)_s.jpg"
            }
            
            completionHandler(true, photos_url as [AnyObject], nil)
        }
        task.resume()
    }
    
    // MARK: - Helpers
    
    func createURLRequest(method: String , path: String , parameters: [String:String]) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = path
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        return request
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }
}
