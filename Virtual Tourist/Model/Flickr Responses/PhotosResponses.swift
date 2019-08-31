//
//  PhotosResponses.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

struct PhotosResponses: Codable {
    let photos: PhotoResponses
    let stat: String
}

struct PhotoResponses: Codable {
    let currentPage: Int
    let totalPages: Int
    let itemsPerPage: Int
    let totalPhotos: String
    let photo: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "page"
        case totalPages = "pages"
        case itemsPerPage = "perpage"
        case totalPhotos = "total"
        case photo
    }
}
