//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

class FlickrAPI {
    
    static let apiKey = "f9bc57ca5e5fc9ffcf570e4f2de7d269"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        static let apiKeyParam = "&api_key=\(FlickrAPI.apiKey)"
        static let jsonFormatParam = "&format=json&nojsoncallback=1"
        
        case searchPhotosWithCoordinate(latitude: Double, longitude: Double, itemPerPage: Int, page: Int)
        
        var stringValue: String {
            switch self {
            case .searchPhotosWithCoordinate(let latitude, let longitude, let itemPerPage, let page):
                return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKeyParam + "&lat=\(latitude)" + "&lon=\(longitude)" + "&per_page=\(itemPerPage)" + "&page=\(page)" + Endpoints.jsonFormatParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getSearchPhotosResults(latitude: Double, longitude: Double, itemPerPage: Int, page: Int, completion: @escaping ([FlickrPhoto]?, Error?) -> Void) {
        
        let url = Endpoints.searchPhotosWithCoordinate(latitude: latitude, longitude: longitude, itemPerPage: itemPerPage, page: page).url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error!)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(PhotosResponses.self, from: data)
                completion(response.photos.photo, nil)
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponses.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        print(String(data: data, encoding: .utf8)!)
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
}
