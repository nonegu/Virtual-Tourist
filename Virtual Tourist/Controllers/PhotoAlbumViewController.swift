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
    
    // DataController will be created by dependency injection
    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // To update the collectionView, BlockOperation will be used
    var blockOperations = [BlockOperation]()
    
    var urls = [URL]()
    
    var isDownloading = false
    
    let itemPerPage = 18
    var pageNum = 0
    
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupFetchedResults()
        // MARK: Get photos for the pins that does not have saved photos.
        if fetchedResultsController.fetchedObjects?.count == 0 {
            isDownloading = true
            setCollectionViewLoadingState(true)
            FlickrAPI.getSearchPhotosResults(latitude: pin.latitude, longitude: pin.longitude, itemPerPage: itemPerPage, page: pageNum, completion: handleGetSearchPhotosResults(totalPages:photos:error:))
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
    
    // to avoid faulty notifications fetchedresultscontroller should be set to nil
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @IBAction func newCollectionPressed(_ sender: UIButton) {
        setCollectionViewLoadingState(true)
        isDownloading = true
        FlickrAPI.getSearchPhotosResults(latitude: pin.latitude, longitude: pin.longitude, itemPerPage: itemPerPage, page: pageNum, completion: handleGetSearchPhotosResults(totalPages:photos:error:))
    }
    
    func handleGetSearchPhotosResults(totalPages: Int?, photos: [FlickrPhoto]?, error: Error?) {
        isDownloading = false
        guard let photos = photos else {
            // if no FlickrPhoto received from the server, no future download will be made
            // collectionView should be reloaded to show "No images found" labelView
            collectionView.reloadData()
            print(error!)
            return
        }
        guard let totalPages = totalPages else {
            print(error!)
            return
        }
        // randomizing page number can return same images due to structure of flickr
        // instead increasing pageNumber has higher chance to get different photos
        if totalPages > pageNum {
            pageNum += 1
        } else {
            pageNum = 0
        }
        urls = FlickrAPI.createPhotoURLsFrom(photos: photos)
        print(urls)
        if urls != [] {
            // if less then requested photo returned from the server, the app will only create cells for returned photos
            isDownloading = true
            createPlaceholderPhotos(numberOfPhotos: (urls.count - fetchedResultsController.fetchedObjects!.count))
            for url in urls {
                FlickrAPI.getPhotoData(url: url, completion: handleGetPhotoData(imageData:url:error:))
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
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
    
    func handleGetPhotoData(imageData: Data?, url: URL, error: Error?) {
        isDownloading = false
        guard let data = imageData else {
            print("Downloading at \(url) has failed: \(error!.localizedDescription)")
            return
        }
        photoToUpdate(imageData: data, url: url)
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
    
    func photoToUpdate(imageData: Data, url: URL) {
        // following will get the item number, and it will be used to updated related photos in CoreData
        guard let item = urls.firstIndex(where: { (searchUrl) -> Bool in
            searchUrl.absoluteString == url.absoluteString
        }) else {
            return
        }
        // the section will always be 0, since the database is constructed to hold single section.
        let indexPath = IndexPath(item: item, section: 0)
        let photo = fetchedResultsController.object(at: indexPath)
        photo.image = imageData
        
    }
    
    func setCollectionViewLoadingState(_ isLoading: Bool) {
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
