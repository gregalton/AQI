//
//  LocationManager.swift
//  AQI
//
//  Created by Greg Alton on 6/26/24.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    func didUpdateLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    weak var delegate: LocationManagerDelegate?
    var lastLocation: CLLocation?

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    // CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.didChangeAuthorization(manager, didChangeAuthorization: status)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        delegate?.didUpdateLocation(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
