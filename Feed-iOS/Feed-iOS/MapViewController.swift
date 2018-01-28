//
//  MapViewController.swift
//  Feed-iOS
//
//  Created by Varun Ballari on 1/27/18.
//  Copyright © 2018 Akhila Ballari. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var map: MKMapView!
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        getBanks()
        
    }

    func getBanks() {
        let urlstring = "https://feed-coc.herokuapp.com/allFoodBanks"
        
        let url = URL(string: urlstring)!
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _: Data = data, let _: URLResponse = response, error == nil else {
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let success = json["success"] as? Bool {
                    if success {

                        for i in (json["lat, lng"] as? [[Double]])! {
                            let coordinate = CLLocationCoordinate2D(latitude: i[0], longitude: i[1])

                            DispatchQueue.main.async {
                                self.putOnMap(coordinate: coordinate)
                            }
                        }
                        
                    } else {
                        
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        }
        
        task.resume()

    }
    
    func putOnMap(coordinate: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        self.map.setRegion(viewRegion, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.map.addAnnotation(self.annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.currentLocation = userLocation

                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                map.setRegion(viewRegion, animated: false)
                annotation.coordinate = userLocation.coordinate
                self.map.addAnnotation(self.annotation)

            }
        }
    }
}
