//
//  MockLocationManager.swift
//  AQITests
//
//  Created by Greg Alton on 6/27/24.
//

import CoreLocation
@testable import AQI

class MockLocationManager: LocationManager {
    var requestLocationCalled = false
    
    override func requestLocation() {
        requestLocationCalled = true
        // Simulate a location update
        let location = CLLocation(latitude: 31.6893785, longitude: -85.9607448)
        delegate?.didUpdateLocation(location)
    }
}
