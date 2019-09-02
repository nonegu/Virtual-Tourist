//
//  PhotoAlbumViewController+MapViewDelegate.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 2.09.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    
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
}
