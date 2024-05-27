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
        super.viewWillAppear(animated)
        UdacityClient.getStudenLocations(completion: handleStudenLocationsResponse(locations:error:))
        UdacityClient.getMyPinLocation(completion: handleGetMyPinLocationResponse(success:error:))
    }
    
    func handleGetMyPinLocationResponse(success: Bool, error: Error?) {
        if let error = error {
            self.showAlertController(title: "Error loading my pin location", message: error.localizedDescription, actions: [.init(title: "Cancel", style: .default)])
        }
    }
    
    func handleStudenLocationsResponse(locations: [StudentLocation], error: Error?) {
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
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        UdacityClient.logout {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func postNewInformationTapped(_ sender: UIBarButtonItem) {
        if StudentInformationModel.myPin != nil {
            showOverwritePinAlert()
        } else {
            showCreateNewPinAlert()
        }
    }
    
    func showOverwritePinAlert() {
        showAlertController(title: "Location detected", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", actions: [
            .init(title: "Overwrite", style: .default, handler: handleCreate_OverwriteAction(action:)),
            .init(title: "Cancel", style: .cancel)
        ])
    }
    
    func handleCreate_OverwriteAction( action: UIAlertAction) {
        performSegue(withIdentifier: "informationPostingView", sender: self)
    }
    
    func showCreateNewPinAlert() {
        showAlertController(title: "No Location detected", message: "You Dont have a Student Location Posted. Would You Like to Create a New One?", actions: [
            .init(title: "Create", style: .default, handler: handleCreate_OverwriteAction(action:)),
            .init(title: "Cancel", style: .cancel)
        ])
    }
}
