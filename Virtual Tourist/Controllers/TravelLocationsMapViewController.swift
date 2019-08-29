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
    var fetchedResultsController: NSFetchedResultsController<LatestLocation>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        lpgr.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(lpgr)
        
        setupFetchResults()
        setRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    func setRegion() {
        // when the user opens the app for the first time, there will not be any objects to fetch
        // the default value of the center is set as Apple HQ
        let center = CLLocationCoordinate2D(latitude: fetchedResultsController.fetchedObjects?.first?.latitude ?? 37.33182, longitude: fetchedResultsController.fetchedObjects?.first?.longitude ?? -122.03118)
        let span = MKCoordinateSpan(latitudeDelta: fetchedResultsController.fetchedObjects?.first?.latitudeDelta ?? 0.02, longitudeDelta: fetchedResultsController.fetchedObjects?.first?.longitudeDelta ?? 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            addAnnotation(with: coordinate)
        }
    }
    
    func addAnnotation(with coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "New annotation"
        annotation.subtitle = "A new one"
        mapView.addAnnotation(annotation)
    }
    
    // MARK: Saving the visible region after deleting the latest.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        deletePreviousLocations()
        
        let latestLocation = LatestLocation(context: dataController.viewContext)
        let region = mapView.region
        latestLocation.latitude = region.center.latitude
        latestLocation.longitude = region.center.longitude
        latestLocation.latitudeDelta = region.span.latitudeDelta
        latestLocation.longitudeDelta = region.span.longitudeDelta
        
        try? dataController.viewContext.save()
        print("latitude: \(latestLocation.latitude) longitude: \(latestLocation.longitude)")
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    fileprivate func setupFetchResults() {
        let fetchRequest: NSFetchRequest<LatestLocation> = LatestLocation.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Delete function is used to keep only single value in LatestLocation
    fileprivate func deletePreviousLocations() {
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
