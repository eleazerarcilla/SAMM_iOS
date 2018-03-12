//
//  ViewController.swift
//  SAMM
//
//  Created by Eleazer Arcilla on 06/03/2018.
//  Copyright © 2018 Eleazer Arcilla. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Firebase

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var mapView: GMSMapView!
    var ref: DatabaseReference!
    var locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.settings.myLocationButton=true
        mapView.isMyLocationEnabled=true
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        do {
            if let styleURL = Bundle.main.url(forResource: "maps_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.mySQLDestinationProvider()
        self.positionELoops()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.showCurrentLocationOnMap()
        self.locationManager.stopUpdatingLocation()
    }
    func showCurrentLocationOnMap(){
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: 14)
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.mapView.frame.size.width, height: self.mapView.frame.size.height))
        let mapView = GMSMapView.map(withFrame: rect, camera: camera)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Current Location"
        marker.appearAnimation=GMSMarkerAnimation.pop
        marker.map = mapView
    }
    func mySQLDestinationProvider(){
        let mySQLDestinationAPIURL = "http://meadumandal.website/sammAPI/getDestinations.php?"
        guard let url = URL(string: mySQLDestinationAPIURL) else {return}
        let alert = UIAlertController(title: nil, message: "Initializing data...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            do{
                let destinations = try JSONDecoder().decode([DestinationContents].self, from:data)
                for entry in destinations {
                    DispatchQueue.main.async
                        {
                            let position = CLLocationCoordinate2D(latitude: Double(entry.Lat)!, longitude: Double(entry.Lng)!)
                            let marker = GMSMarker(position: position)
                            marker.icon = UIImage(named: "e-loopsw")
                            marker.title = entry.Description
                            marker.map = self.mapView
                    }
                 
                }
                self.dismiss(animated: false, completion: nil)
                //dismissViewControllerAnimated(false, completion: nil)
            }catch let jsonErr{ print("Error serializing JSON:", jsonErr)}
            }.resume()
    }
    
    func positionELoops(){
        var driverMarker: Dictionary = [String:GMSMarker]()
        ref = Database.database().reference().child("drivers")
        ref.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for entry in postDict{
                DispatchQueue.main.async
                    {
                        if String(entry.key)  != "connections" ||  String(entry.key) != "lastOnline"
                        {
                        guard let Lat = entry.value["Lat"] as? Double else {return}
                        guard let Lng = entry.value["Lng"] as? Double else{return}
                        guard let PrevLat = entry.value["PrevLat"] as? Double else {return}
                        guard let PrevLng = entry.value["PrevLng"] as? Double else{return}
                        let oldpos = CLLocationCoordinate2D(latitude: PrevLat, longitude:  PrevLng)
                        let newpos = CLLocationCoordinate2D(latitude: Lat, longitude:  Lng)
                        let marker = driverMarker[entry.key]
                            if marker == nil
                            {
                                let tempPos = CLLocationCoordinate2D(latitude: Lat, longitude:  Lng)
                                let marker = GMSMarker(position: tempPos)
                                driverMarker[entry.key] = marker
                            }
                        marker?.position = CLLocationCoordinate2D(latitude: Lat, longitude:  Lng)
                        marker?.icon = UIImage(named: "e-loop")
                        marker?.map = self.mapView
                        marker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        marker?.appearAnimation = GMSMarkerAnimation.pop
                        marker?.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldpos, toCoordinate: newpos))
                        }
                }
            }
           
        })
    }
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

