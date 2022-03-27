//
//  ViewController.swift
//  GB_hw
//
//  Created by Сергей Зайцев on 10.03.2022.
//

import UIKit
import GoogleMaps
import RealmSwift
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView?
    var locationManager: CLLocationManager!
    let coordinate = CLLocationCoordinate2D(latitude: 55.878626, longitude: 37.719)
    var beginBackgruondTask: UIBackgroundTaskIdentifier?
    var routePath: GMSMutablePath?
    var route: GMSPolyline?
    var isTracking:Bool = false
    var routeArray = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }
    
    func configureTimer(){
        beginBackgruondTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let strongSelf = self?.beginBackgruondTask else { return }
            UIApplication.shared.endBackgroundTask(strongSelf)
        })
    }
    
    func configureMap(){
        let camera = GMSCameraPosition.init(target: coordinate, zoom: 17)
        mapView?.camera = camera
    }
    
    func configureLocationManager(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func moveCamera(location:CLLocation){
        let camera = GMSCameraPosition.init(target: location.coordinate, zoom: 17)
        mapView?.camera = camera
    }
    
    func addPinToMap(location:CLLocation){
        let marker = GMSMarker(position: location.coordinate)
        marker.map = mapView
    }
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(coordinate)
        routePath?.add(location.coordinate)
        route?.path = routePath
        moveCamera(location: location)
        if isTracking{
            saveToArrayLocation(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension ViewController{
    
    func startTracking(){
        locationManager.startUpdatingLocation()
        route = GMSPolyline()
        route?.strokeWidth = 3
        route?.strokeColor = .red
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func startTrackingFromBase(){
        
        let realm = try! Realm()
        let newPath = GMSMutablePath()
        let coordArray = realm.objects(RouteRealm.self).last
        for coord in coordArray!.locationArray{
            let coordinates = CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.long)
            print(coord.lat, coord.long)
            newPath.add(coordinates)
        }
        routePath = newPath
        route = GMSPolyline()
        route?.strokeWidth = 3
        route?.strokeColor = .red
        route?.map = mapView
        mapView?.camera = GMSCameraPosition(latitude: newPath.coordinate(at: 1).latitude, longitude: newPath.coordinate(at: 1).longitude, zoom: 17)
        isTracking = true
    }
    
    func stopTracking(){
        locationManager.stopUpdatingLocation()
        saveToBaseLocation(locationArray: routeArray)
        clearTrack()
        isTracking = false
    }
    
    func clearTrack(){
         routeArray.removeAll()
         route?.map = nil
    }
    
    func checkTracking(){
        if isTracking{
            let alert = UIAlertController(title: "Подождите", message: "Остановить трэк", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                self?.stopTracking()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController{
    @IBAction func startTrack(_ sender: UIButton){
        clearTrack()
        startTracking()
    }
    
    @IBAction func stopTrack(_ sender: UIButton){
        stopTracking()
    }
    
    @IBAction func previouslyRoute(_ sender: UIButton){
        checkTracking()
        startTrackingFromBase()
    }
    
}


extension ViewController{
    
    func saveToArrayLocation(location:CLLocation){
        routeArray.append(location)
    }
    
    func saveToBaseLocation(locationArray:[CLLocation]){
        
        let realm = try! Realm()
        
        let routeCoord = RouteRealm()
        routeCoord.name = "Маршрут"
        
        for locCoord in locationArray{
            let lat = locCoord.coordinate.latitude
            let long = locCoord.coordinate.longitude
            let coord = Coordinates(value: ["lat": lat,"long": long])
            print(coord)
            routeCoord.locationArray.append(coord)
        }
        print(routeCoord.locationArray)
        try! realm.write {
            
            realm.add(routeCoord)
        }
    }
}
