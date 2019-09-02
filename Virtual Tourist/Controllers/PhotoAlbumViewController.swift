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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupFetchedResults()
        // MARK: Get photos for the pins that does not have saved photos.
        if fetchedResultsController.fetchedObjects?.count == 0 {
            isDownloading = true
            FlickrAPI.getSearchPhotosResults(latitude: pin.latitude, longitude: pin.longitude, itemPerPage: 12, page: 1, completion: handleGetSearchPhotosResults(photos:error:))
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
    
    func handleGetSearchPhotosResults(photos: [FlickrPhoto]?, error: Error?) {
        guard let photos = photos else {
            isDownloading = false
            collectionView.reloadData()
            print(error!)
            return
        }
        urls = createPhotoURLsFrom(photos: photos)
        createPlaceholderPhotos()
        getPhotoData(urls: urls, completion: handleGetPhotoData(success:error:))
        
    }
    
    func createPlaceholderPhotos() {
        for _ in urls {
            let photo = Photo(context: self.dataController.viewContext)
            photo.image = UIImage(named: "placeholder")?.jpegData(compressionQuality: 1.0)
            photo.pin = self.pin
        }
        try? self.dataController.viewContext.save()
    }
    
    func handleGetPhotoData(success: Bool, error: Error?) {
        if success {
            print(true)
        } else {
            print(error!)
        }
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
    
    func setupMapView() {
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        setRegion()
        addAnnotation()
    }
    
    func setRegion() {
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.title = pin.name
        mapView.addAnnotation(annotation)
    }
    
    func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 4
        collectionView.collectionViewLayout = layout
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
    
    private func createPhotoURLsFrom(photos: [FlickrPhoto], size: String = "q") -> [URL] {
        var urls = [URL]()
        for photo in photos {
            let photoURL = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size).jpg")!
            urls.append(photoURL)
        }
        return urls
    }
    
}
