//
//  ErrorResponses.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation

struct ErrorResponses: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension ErrorResponses: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
