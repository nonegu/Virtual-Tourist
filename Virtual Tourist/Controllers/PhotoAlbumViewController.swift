//
//  PhotoAlbumView.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 29.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    /// The pin whose photos are being displayed
    var pin: Pin!
    
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var blockOperations = [BlockOperation]()
    
    var urls = [URL]()
    
    var isDownloading = false
    
    var pageNum = 0
    
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupFetchedResults()
        // MARK: Get photos for the pins that does not have saved photos.
        if fetchedResultsController.fetchedObjects?.count == 0 {
            isDownloading = true
            FlickrAPI.getSearchPhotosResults(latitude: pin.latitude, longitude: pin.longitude, itemPerPage: 12, page: pageNum, completion: handleGetSearchPhotosResults(totalPages:photos:error:))
        }
        
        setupLayout()
        collectionView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(handleDelete))
        navigationItem.rightBarButtonItem?.isEnabled = false
        newCollectionButton.isEnabled = false
        navigationItem.title = pin.name
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func newCollectionPressed(_ sender: UIButton) {
        setCollectionViewLoadingState(true)
        isDownloading = true
        FlickrAPI.getSearchPhotosResults(latitude: pin.latitude, longitude: pin.longitude, itemPerPage: 12, page: pageNum, completion: handleGetSearchPhotosResults(totalPages:photos:error:))
    }
    
    
    func handleGetSearchPhotosResults(totalPages: Int?, photos: [FlickrPhoto]?, error: Error?) {
        guard let photos = photos else {
            // if no FlickrPhoto received from the server, no future download will be made
            isDownloading = false
            // collectionView should be reloaded to show "No images found" labelView
            collectionView.reloadData()
            print(error!)
            return
        }
        guard let totalPages = totalPages else {
            print(error!)
            return
        }
        // randomizing page number to fetch different set of images
        pageNum = Int.random(in: 0...totalPages)
        urls = createPhotoURLsFrom(photos: photos)
        createPlaceholderPhotos(numberOfPhotos: (12 - fetchedResultsController.fetchedObjects!.count))
        getPhotoData(urls: urls, completion: handleGetPhotoData(success:error:))
        
    }
    
    func createPlaceholderPhotos(numberOfPhotos: Int) {
        if numberOfPhotos > 0{
            for _ in 0..<numberOfPhotos {
                let photo = Photo(context: self.dataController.viewContext)
                photo.image = UIImage(named: "placeholder")?.jpegData(compressionQuality: 1.0)
                photo.pin = self.pin
            }
            try? self.dataController.viewContext.save()
        }
    }
    
    func handleGetPhotoData(success: Bool, error: Error?) {
        if success {
            print(true)
        } else {
            print(error!)
        }
        setCollectionViewLoadingState(false)
    }
    
    @objc func handleDelete() {
        photosToDelete(at: collectionView.indexPathsForSelectedItems!)
        navigationItem.rightBarButtonItem?.isEnabled = false
        newCollectionButton.isEnabled = true
    }
    
    func photosToDelete(at selectedItems: [IndexPath]) {
        for indexPath in selectedItems {
            let photoToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(photoToDelete)
        }
        try? dataController.viewContext.save()
    }
    
    fileprivate func setCollectionViewLoadingState(_ isLoading: Bool) {
        if isLoading {
            let yAxis = (collectionView.frame.minY) + (collectionView.frame.maxY - collectionView.frame.minY)/2
            activityIndicator.frame = CGRect(x: collectionView.frame.maxX/2, y: yAxis, width: 20, height: 20)
            activityIndicator.color = UIColor.darkGray
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                self.collectionView.alpha = 0.5
            }
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.collectionView.alpha = 1.0
            }
        }
    }
    
}
