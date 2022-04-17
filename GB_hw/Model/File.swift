//
//  File.swift
//  GB_hw
//
//  Created by Сергей Зайцев on 03.04.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

final class LocationManager: NSObject { static
    let instance = LocationManager()
private override init() {
    super.init()
configureLocationManager() }
let locationManager = CLLocationManager()
let location: Variable<CLLocation?> = Variable(nil)
    func startUpdatingLocation() { locationManager.startUpdatingLocation()
    }
    func stopUpdatingLocation() { locationManager.stopUpdatingLocation()
    }
    private func configureLocationManager() {
    locationManager.delegate = self locationManager.allowsBackgroundLocationUpdates = true locationManager.pausesLocationUpdatesAutomatically = false locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters locationManager.startMonitoringSignificantLocationChanges() locationManager.requestAlwaysAuthorization()
    } }
    extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
    locations: [CLLocation]) {
    self.location.value = locations.last }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error) }
    }
