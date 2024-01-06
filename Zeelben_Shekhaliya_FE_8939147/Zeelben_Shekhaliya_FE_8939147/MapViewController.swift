//
//  MapViewController.swift
//  Zeelben_Shekhaliya_FE_8939147
//
//  Created by Zeel Shekhaliya on 2023-12-07.
//

import UIKit
import MapKit

class MapViewController: ExtensionViewController {
    
    var enteredLocation : String?
    var sourceLocation : CLLocationCoordinate2D?
    var DestinationLocation : CLLocationCoordinate2D?
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .white
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc func plusButtonTapped() {
        showAlertMessage(title: "Enter your new destination here!")
    }

    @IBAction func carMode(_ sender: Any) {
        requestDirections(from: sourceLocation, to: DestinationLocation, mode: .automobile)
    }
    @IBAction func cycleMode(_ sender: Any) {
        requestDirections(from: sourceLocation, to: DestinationLocation, mode: .transit)
    }
    @IBAction func walkMode(_ sender: Any) {
        requestDirections(from: sourceLocation, to: DestinationLocation, mode: .walking)
    }
    
    @IBAction func ZoomSlider(_ sender: UISlider) {
        let newZoomLevel = sender.value
        updateMapZoomLevel(newZoomLevel)
    }

    func updateMapZoomLevel(_ zoomLevel: Float) {
            let currentRegion = mapView.region
            let span = MKCoordinateSpan(latitudeDelta: Double(120 / pow(500, zoomLevel)), longitudeDelta: Double(120 / pow(500, zoomLevel)))
            let newRegion = MKCoordinateRegion(center: currentRegion.center, span: span)
            mapView.setRegion(newRegion, animated: true)
        }
    
    //Change City
    func updateMapWithCityCoordinate(_ cityCoordinate: CLLocationCoordinate2D) {
            let region = MKCoordinateRegion(center: cityCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            let enteredCityAnnotation = MKPointAnnotation()
            enteredCityAnnotation.coordinate = cityCoordinate
            enteredCityAnnotation.title = "Entered City Location"
            mapView.addAnnotation(enteredCityAnnotation)

            self.requestDirections(from: cityCoordinate, to: self.DestinationLocation, mode: .automobile)
        }
    
    //alert
    func showAlertMessage(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .alphabet
        }

        let changeCity = UIAlertAction(title: "Change City", style: .default) { [unowned alert] (action) in
            if let textField = alert.textFields?.first {
                self.enteredLocation = textField.text
                
                self.getLocationCoordinates(from: self.enteredLocation ?? "waterloo") { enteredUserCoordinate in
                    guard let enteredUserCoordinates = enteredUserCoordinate else {
                        print("Error getting coordinates for entered user location")
                        return
                    }
                    
                    self.updateMapWithCityCoordinate(enteredUserCoordinates)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(changeCity)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}

extension MapViewController : MKMapViewDelegate, CLLocationManagerDelegate {
    
    func getLocationCoordinates(from address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                let coordinates = placemark.location?.coordinate
                completion(coordinates)
            } else {
                print("No coordinates found for \(address)")
                completion(nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first?.coordinate else {
            return
        }

        getLocationCoordinates(from: enteredLocation ?? "waterloo") { enteredUserCoordinate in
            guard let enteredUserCoordinate = enteredUserCoordinate else {
                print("Error getting coordinates for entered user location")
                return
            }
            
            self.sourceLocation = enteredUserCoordinate
            self.DestinationLocation = userLocation
            
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)

            // Add an annotation for the user's location
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            userAnnotation.title = "You are here"
            self.mapView.addAnnotation(userAnnotation)

            // Add an annotation for the entered user's location
            let enteredUserAnnotation = MKPointAnnotation()
            enteredUserAnnotation.coordinate = enteredUserCoordinate
            enteredUserAnnotation.title = "Entered User Location"
            self.mapView.addAnnotation(enteredUserAnnotation)
            
            self.requestDirections(from: enteredUserCoordinate, to: userLocation, mode: .automobile)
        }
    }
 
    func requestDirections(from source: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D?, mode: MKDirectionsTransportType) {
            guard let sourceCoordinate = source, let destinationCoordinate = destination else {
                print("Source or destination coordinate is nil")
                return
            }

            let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = mode

            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let response = response, error == nil else {
                    print("Error getting directions: \(error?.localizedDescription ?? "Unknown error")")
                    return
            }

                // Remove existing overlays
                self.mapView.removeOverlays(self.mapView.overlays)

                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                for step in route.steps {
                    print(step.instructions)
                }
            }
        }
    
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolyline {
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
                return renderer
            }
            return MKOverlayRenderer()
        }
}
