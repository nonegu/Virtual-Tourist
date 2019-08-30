//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
}
