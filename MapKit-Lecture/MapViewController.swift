//
//  ViewController.swift
//  MapKit-Lecture
//
//  Created by casandra grullon on 2/24/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    
    private let coreLocationSession = CoreLocationSession()
    private var userTrackingButton: MKUserTrackingButton!
    
    private var isShowingNewAnnotations = false
    
    private var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        textField.delegate = self
        
        userTrackingButton = MKUserTrackingButton(frame: CGRect(x: 20, y: 20, width: 40, height: 30))
        userTrackingButton.backgroundColor = .systemTeal
        mapView.addSubview(userTrackingButton)
        userTrackingButton.mapView = mapView
        loadMap()
        mapView.delegate = self
    }
    
    private func loadMap() {
        let annotations = makeAnnotations()
        mapView.addAnnotations(annotations)
    }

    private func makeAnnotations() -> [MKPointAnnotation] {
        var annotations = [MKPointAnnotation]()
        for location in Location.getLocations() {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.coordinate = location.coordinate
            annotations.append(annotation)
        }
        isShowingNewAnnotations = true
        self.annotations = annotations
        return annotations
    }
    
    private func convertPlaceNameToCoordinate(_ placename: String) {
        coreLocationSession.convertPlaceNameToCoordinate(addressString: placename) { (result) in
            switch result {
            case .failure(let error):
                print("geocoding error \(error)")
            case .success(let coordinate):
                // animation zooming in to given coordinate
                let region =  MKCoordinateRegion(center: coordinate, latitudinalMeters: 1600, longitudinalMeters: 1600)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    

    
}
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()

        guard let searchText = textField.text, !searchText.isEmpty else {
            return true
        }
        
        convertPlaceNameToCoordinate(searchText)
        
        return true
    }
}
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        guard let location = (Location.getLocations().filter {$0.title == annotation.title }).first else {
            return
        }
        guard let detailVC = storyboard?.instantiateViewController(identifier: "LocationDetailViewController", creator: { (coder) in
            return LocationDetailViewController(coder: coder, location: location)
        }) else {
            fatalError("could not access LocationDetailViewController")
        }
        detailVC.modalPresentationStyle = .overCurrentContext
        present(detailVC, animated: true)
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }
        let identifier = "annotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.glyphImage = UIImage(named: "duck")
            annotationView?.glyphTintColor = .yellow
            annotationView?.markerTintColor = .blue
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isShowingNewAnnotations {
            mapView.showAnnotations(annotations, animated: false)
        }
        isShowingNewAnnotations = false
    }
}
