//
//  PhotoAlbumViewController+UICollectionView.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 1.09.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // checking if the fetchedResultsController has objects and how many.
        let count: Int = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        // if number of objects equal to 0, a label presented.
        if count == 0 && !isDownloading {
            collectionView.setEmptyMessage("No images found :(")
        } else {
            collectionView.restore()
            newCollectionButton.isEnabled = true
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.defaultReuseIdentifier, for: indexPath) as! PhotoCell
        let photo = fetchedResultsController.object(at: indexPath)
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
        }
        if isDownloading {
            cell.activityIndicator.startAnimating()
        } else {
            cell.activityIndicator.stopAnimating()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        newCollectionButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        collectionView.cellForItem(at: indexPath)?.alpha = 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems == [] {
            newCollectionButton.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        collectionView.cellForItem(at: indexPath)?.alpha = 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 9
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/3, height: collectionViewSize/3)
    }
    
    func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 4
        collectionView.collectionViewLayout = layout
    }
    
}

extension UICollectionView {
    
    // MARK: Setting a label to show when there are no images to show to the user.
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 12)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    // MARK: Removing the label when there are images to show.
    func restore() {
        self.backgroundView = nil
    }
}
