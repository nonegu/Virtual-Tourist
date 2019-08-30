//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

class FlickrAPI {
    
    static let apiKey = "ENTER_YOUR_API_KEY_HERE"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        static let apiKeyParam = "&api_key=\(FlickrAPI.apiKey)"
        static let jsonFormatParam = "&format=json&nojsoncallback=1"
        
        case searchPhotosWithCoordinate(latitude: Double, longitude: Double, itemPerPage: Int, page: Int)
        
        var stringValue: String {
            switch self {
            case .searchPhotosWithCoordinate(let latitude, let longitude, let itemPerPage, let page):
                return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKeyParam + "&lat=\(latitude)" + "lon=\(longitude)" + "&per_page=\(itemPerPage)" + "&page=\(page)" + Endpoints.jsonFormatParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
}
