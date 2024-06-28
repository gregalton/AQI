//
//  LocationManagerTests.swift
//  AQITests
//
//  Created by Greg Alton on 6/26/24.
//

import XCTest
import CoreLocation
@testable import AQI

class MockCLLocationManager: CLLocationManager {
    var requestLocationCalled = false
    var requestWhenInUseAuthorizationCalled = false

    override func requestLocation() {
        requestLocationCalled = true
    }

    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
    }
}

class LocationManagerTests: XCTestCase {
    var locationManager: LocationManager!
    var mockCLLocationManager: MockCLLocationManager!
    var delegate: MockLocationManagerDelegate!

    override func setUp() {
        super.setUp()
        mockCLLocationManager = MockCLLocationManager()
        delegate = MockLocationManagerDelegate()
        locationManager = LocationManager(locationManager: mockCLLocationManager)
        locationManager.delegate = delegate
    }

    override func tearDown() {
        locationManager = nil
        mockCLLocationManager = nil
        delegate = nil
        super.tearDown()
    }

    func testRequestLocation() {
        locationManager.requestLocation()
        XCTAssertTrue(mockCLLocationManager.requestWhenInUseAuthorizationCalled)
        XCTAssertTrue(mockCLLocationManager.requestLocationCalled)
    }

    func testDidUpdateLocation() {
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        locationManager.locationManager(mockCLLocationManager, didUpdateLocations: [location])
        XCTAssertEqual(delegate.lastLocation?.coordinate.latitude, location.coordinate.latitude)
        XCTAssertEqual(delegate.lastLocation?.coordinate.longitude, location.coordinate.longitude)
    }

    func testDidFailWithError() {
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        locationManager.locationManager(mockCLLocationManager, didFailWithError: error)
        XCTAssertEqual(delegate.lastError as NSError?, error)
    }
}

class MockLocationManagerDelegate: LocationManagerDelegate {
    var lastLocation: CLLocation?
    var lastError: Error?
    var authStatus: CLAuthorizationStatus?
    
    func didChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authStatus = status
    }

    func didUpdateLocation(_ location: CLLocation) {
        lastLocation = location
    }

    func didFailWithError(_ error: Error) {
        lastError = error
    }
}
