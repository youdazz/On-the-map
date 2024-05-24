//
//  StudenLocationViewController.swift
//  On the Map
//
//  Created by Youda Zhou on 20/5/24.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var annotations: [MKPointAnnotation] = []
        
    override func viewWillAppear(_ animated: Bool) {
        UdacityClient.getStudenLocations(completion: handleStudenLocationsResponse(locations:error:))
    }
    
    func handleStudenLocationsResponse(locations: [StudentLocation], error: Error?) {
        StudentInformationModel.studentInformation = .init(locations: locations)
        if let error = error {
            showAlertController(title: "Error loading data", message: error.localizedDescription, actions: [.init(title: "Cancel", style: .default)])
        }
        updatePins()
    }
    
    func updatePins() {
        let locations = StudentInformationModel.studentInformation?.locations ?? []
        
        for student in locations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView

        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView?.markerTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let subtitle = view.annotation?.subtitle
            guard let url = URL(string: subtitle!!) else {
                errorOpeningLinkAlert()
                return }
            if UIApplication.shared.canOpenURL(url) {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
            } else {
                errorOpeningLinkAlert()
            }
        }
    }
    
    func errorOpeningLinkAlert() {
        showAlertController(title: "Link error", message: "Cannot open student link", actions: [.init(title: "Cancel", style: .default)])
    }
}
