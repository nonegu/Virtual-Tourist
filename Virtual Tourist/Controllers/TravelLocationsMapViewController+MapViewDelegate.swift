//
//  TravelLocationsMapViewController+MapViewDelegate.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 30.08.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func addAnnotation(with coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        placeNameForCoordinate(coordinate: coordinate) { (placeName, error) in
            if let error = error {
                print("No place found: \(error.localizedDescription)")
                annotation.coordinate = coordinate
                annotation.title = "Unknown Place"
                self.persistNewAnnotation(annotation: annotation)
                self.mapView.addAnnotation(annotation)
            } else {
                annotation.coordinate = coordinate
                annotation.title = placeName!
                self.persistNewAnnotation(annotation: annotation)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func persistNewAnnotation(annotation: MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        pin.name = annotation.title
        
        try? dataController.viewContext.save()
    }
    
    func loadPersistedAnnotations() {
        // when user opens the app, following will load all the annotatiton that has been saved before.
        if let fetchedPins = PinsFetchedResultsController.fetchedObjects {
            if fetchedPins.count > 0 {
                for pin in fetchedPins {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    annotation.title = pin.name
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func placeNameForCoordinate(coordinate: CLLocationCoordinate2D, completion: @escaping (String?, Error?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Location not found: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    if let cityName = placemark.locality {
                        completion(cityName, nil)
                    }
                }
            }
        }
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
