//
//  SendDonationViewController.swift
//  Feed-iOS
//
//  Created by Akhila Ballari on 1/27/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SendDonationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    let annotation = MKPointAnnotation()
    
    @IBOutlet var foodLabel: UITextField!
    @IBOutlet var feedsLabel: UITextField!
    @IBOutlet var goodUntilLabel: UITextField!
    @IBOutlet var pickUpLabel: UITextField!
    @IBOutlet var destinationLabel: UITextField!
    
    var food: String!
    var toLocation: String!
    var toLocLat: Double!
    var toLocLong: Double!

    @IBOutlet var round: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        round.layer.cornerRadius = 10
        round.clipsToBounds = true
        
        self.navigationController?.isNavigationBarHidden = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goBack(recognizer:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        foodLabel.text = food
        destinationLabel.text = toLocation
        goodUntilLabel.text = "10"
        feedsLabel.text = "6"
        pickUpLabel.text = "Your Location"
        
        map.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack(recognizer: UISwipeGestureRecognizer) {
        print("left")
        self.dismiss(animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }

        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                map.setRegion(viewRegion, animated: false)
                annotation.coordinate = userLocation.coordinate
                self.map.addAnnotation(self.annotation)
                
                let sourceLocation = userLocation.coordinate
                let destinationLocation = CLLocationCoordinate2D(latitude: toLocLat, longitude: toLocLong)
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
                let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
                
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                let sourceAnnotation = MKPointAnnotation()
                sourceAnnotation.title = "Pickup"
                
                if let location = sourcePlacemark.location {
                    sourceAnnotation.coordinate = location.coordinate
                }
                
                let destinationAnnotation = MKPointAnnotation()
                destinationAnnotation.title = toLocation
                
                if let location = destinationPlacemark.location {
                    destinationAnnotation.coordinate = location.coordinate
                }
                
                self.map.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = sourceMapItem
                directionRequest.destination = destinationMapItem
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                
                directions.calculate {
                    (response, error) -> Void in
                    
                    guard let response = response else {
                        if let error = error {
                            print("Error: \(error)")
                        }
                        
                        return
                    }
                    
                    let route = response.routes[0]
                    self.map.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                }
            }
        }
    }
    

    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    @IBAction func goToUPS(_ sender: Any) {
        self.performSegue(withIdentifier: "goToUPS", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let vc = segue.destination as! UPSViewController
        vc.foodName = self.foodLabel.text
        vc.myLat = appDelegate.currentLocation?.coordinate.latitude
        vc.myLng = appDelegate.currentLocation?.coordinate.longitude
        vc.toLat = self.toLocLat
        vc.toLng = self.toLocLong
        vc.name = self.toLocation
        vc.serving = self.feedsLabel.text
    }
}
