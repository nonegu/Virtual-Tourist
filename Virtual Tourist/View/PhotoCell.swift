//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 31.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    static var defaultReuseIdentifier: String {
        return "\(self)"
    }
}
