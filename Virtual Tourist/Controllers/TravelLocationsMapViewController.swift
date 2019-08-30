//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 29.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var LatestLocationFetchedResultController: NSFetchedResultsController<LatestLocation>!
    var PinsFetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        lpgr.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(lpgr)
        
        setupPinsFetchResults()
        loadPersistedAnnotations()
        
        setupLatestLocationFetchResult()
        setRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
        }
    }

    func setRegion() {
        // when the user opens the app for the first time, there will not be any objects to fetch
        // the default value of the center is set as Apple HQ
        let center = CLLocationCoordinate2D(latitude: LatestLocationFetchedResultController.fetchedObjects?.first?.latitude ?? 37.33182, longitude: LatestLocationFetchedResultController.fetchedObjects?.first?.longitude ?? -122.03118)
        let span = MKCoordinateSpan(latitudeDelta: LatestLocationFetchedResultController.fetchedObjects?.first?.latitudeDelta ?? 0.02, longitudeDelta: LatestLocationFetchedResultController.fetchedObjects?.first?.longitudeDelta ?? 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            addAnnotation(with: coordinate)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a PhotoAlbumViewController, we'll configure its `Pin`
        if let vc = segue.destination as? PhotoAlbumViewController {
            if let pins = PinsFetchedResultsController.fetchedObjects {
                // there will be only one selected annotation at a time
                let annotation = mapView.selectedAnnotations[0]
                // getting the index of the selected annotation to set pin value in destination VC
                guard let indexPath = pins.firstIndex(where: { (pin) -> Bool in
                    pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude
                }) else {
                    return
                }
                vc.pin = pins[indexPath]
                vc.dataController = dataController
            }
        }
    }
    
}

// MARK: FetchedResultsController delegate methods

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    fileprivate func setupLatestLocationFetchResult() {
        let fetchRequest: NSFetchRequest<LatestLocation> = LatestLocation.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        LatestLocationFetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        LatestLocationFetchedResultController.delegate = self
        do {
            try LatestLocationFetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func setupPinsFetchResults() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        PinsFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        PinsFetchedResultsController.delegate = self
        do {
            try PinsFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Delete function is used to keep only single value in LatestLocation
    func deletePreviousLocations() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "LatestLocation")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try dataController.viewContext.execute(deleteRequest)
            try dataController.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
