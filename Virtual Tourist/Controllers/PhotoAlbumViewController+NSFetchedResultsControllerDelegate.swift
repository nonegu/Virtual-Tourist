//
//  PhotoAlbumViewController+NSFetchedResultsControllerDelegate.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 1.09.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: {
                self.collectionView.insertItems(at: [newIndexPath!])
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: {
                self.collectionView.deleteItems(at: [indexPath!])
            }))
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }) { (completed) in }
        self.newCollectionButton.isEnabled = true
    }
    
    func setupFetchedResults() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func getPhotoData(urls: [URL], completion: @escaping (Bool, Error?) -> Void) {
        for url in urls {
            isDownloading = true
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    completion(false, error!)
                    return
                }
                // following will get the item number, and it will be used to updated related photos in CoreData
                guard let item = urls.firstIndex(where: { (searchUrl) -> Bool in
                    searchUrl.absoluteString == url.absoluteString
                }) else {
                    return
                }
                // the section will always be 0, since the database is constructed to hold single section.
                let photo = self.fetchedResultsController.object(at: IndexPath(item: item, section: 0))
                photo.image = data
                try? self.dataController.viewContext.save()
            }
            isDownloading = false
            task.resume()
        }
        completion(true, nil)
        
    }
    
    func createPhotoURLsFrom(photos: [FlickrPhoto], size: String = "q") -> [URL] {
        var urls = [URL]()
        for photo in photos {
            let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
            urls.append(photoURL)
        }
        return urls
    }
    
}
