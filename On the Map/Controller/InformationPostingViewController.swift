//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Youda Zhou on 24/5/24.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: IBOutlet
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var mark: CLPlacemark?
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.markerTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: IBAction
    @IBAction func didTapFindLocation() {
        let geoCoder = CLGeocoder()
        let addressString = locationTextField.text ?? ""
        activityIndicator.startAnimating()
        geoCoder.geocodeAddressString(addressString) { results, error in
            self.activityIndicator.stopAnimating()
            guard let results = results else {
                self.showAlertController(title: "Error", message: error?.localizedDescription ?? "", actions: [.init(title: "Cancel", style: .default)])
                return
            }
            self.changeViewVisibility()
            self.mark = results.first
            self.updatePin()
        }
    }
    
    func changeViewVisibility() {
        locationTitle.isHidden = true
        locationTextField.isHidden = true
        findLocationButton.isHidden = true
        
        urlLabel.isHidden = false
        urlTextField.isHidden = false
        submitButton.isHidden = false
        mapView.isHidden = false
    }
    
    func updatePin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mark!.location!.coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    @IBAction func didTapSubmitButton() {
        activityIndicator.startAnimating()
        UdacityClient.getUserInformation(completion: handleUserInformationResponse(success:error:))
    }
    
    func handleUserInformationResponse(success: Bool, error: Error?) {
        if success {
            guard let location = mark?.location else { 
                showError(message: "Location error")
                return }
            UdacityClient.postUserInformation(mapString: locationTextField.text ?? "", mediaUrl: urlTextField.text ?? "", latitude: Float(location.coordinate.latitude), longitude: Float(location.coordinate.longitude), completion: handlePostInformationResponse(success:error:))
        } else {
            activityIndicator.stopAnimating()
            showError(message: error?.localizedDescription)
        }
    }
    
    func handlePostInformationResponse(success: Bool, error: Error?) {
        activityIndicator.stopAnimating()
        if success {
            self.dismiss(animated: true)
        } else {
            showError(message: error?.localizedDescription)
        }
    }
    
    func showError(message: String?) {
        showAlertController(title: "Error", message: message ?? "", actions: [.init(title: "Cancel", style: .default)])
    }
    
    @IBAction func didTapCancel(_ sender: Any?) {
        self.dismiss(animated: true)
    }
}
