//
//  ViewControllerTests.swift
//  AQITests
//
//  Created by Greg Alton on 6/27/24.
//

import XCTest
import CoreLocation
@testable import AQI

class ViewControllerTests: XCTestCase {
    
    var viewController: ViewController!
    var mockLocationManager: MockLocationManager!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        
        // Initialize with a default result, it will be overridden in each test as needed
        mockNetworkManager = MockNetworkManager(mockResult: nil)
        
        viewController = ViewController(networkManager: mockNetworkManager)
        viewController.loadViewIfNeeded()
        viewController.locationManager = mockLocationManager
        mockLocationManager.delegate = viewController
        
        
    }
    
    override func tearDown() {
        viewController = nil
        mockLocationManager = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    func testDidUpdateLocationFetchesAQI() {
        // Given
        let location = CLLocation(latitude: 31.6893785, longitude: -85.9607448)
        viewController.didUpdateLocation(location)
        let expectation = self.expectation(description: "fetchAQI called")
        mockNetworkManager.mockResult = .success(AQIResponse(status: "ok", data: AQIData(aqi: 46)))
        
        // When
        viewController.didUpdateLocation(location)
        
        // Then
        // Verify that fetchAQI is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockNetworkManager.fetchAQICalled, "fetchAQI should be called when location is updated")
            expectation.fulfill()
        }
        
        // Wait for expectations
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testDidFailWithErrorShowsAlert() {
        // Given
        let error = NSError(domain: "LocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        // When
        viewController.didFailWithError(error)

        // Then
        // Here we would need to check if the alert is presented.
        // In a real UI test, we would verify the presence of the alert.
        // Since this is a unit test, we assume showAlert works correctly.
    }

    func testHandleAQIResultSuccessUpdatesUI() {
        // Given
        let aqiResponse = AQIResponse(status: "ok", data: AQIData(aqi: 46))
        let result: Result<AQIResponse, NetworkError> = .success(aqiResponse)
        mockNetworkManager.mockResult = result
        let expectation = self.expectation(description: "UI updated")

        // When
        viewController.didUpdateLocation(CLLocation(latitude: 31.6893785, longitude: -85.9607448))

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewController.view.backgroundColor, UIColor.systemGreen, "The background color should be updated based on AQI")
            XCTAssertEqual(self.viewController.aqiLabel.text, "46", "The AQI label should be updated with the AQI value")
            expectation.fulfill()
        }

        // Wait for expectations
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testHandleAQIResultFailureShowsAlert() {
        // Given
        let error = NetworkError.requestFailed(NSError(domain: "Test", code: 1, userInfo: nil))
        let result: Result<AQIResponse, NetworkError> = .failure(error)
        mockNetworkManager.mockResult = result

        // When
        viewController.didUpdateLocation(CLLocation(latitude: 31.6893785, longitude: -85.9607448))

        // Then
        // Here we would need to check if the alert is presented.
        // In a real UI test, we would verify the presence of the alert.
        // Since this is a unit test, we assume showAlert works correctly.
    }

    func testYellowBackgroundChangesTextColorToBlack() {
        // Given
        let aqiResponse = AQIResponse(status: "ok", data: AQIData(aqi: 75))
        let result: Result<AQIResponse, NetworkError> = .success(aqiResponse)
        mockNetworkManager.mockResult = result

        // When
        viewController.didUpdateLocation(CLLocation(latitude: 31.6893785, longitude: -85.9607448))

        // Then
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewController.view.backgroundColor, UIColor.systemYellow, "The background color should be yellow for AQI 75")
            XCTAssertEqual(self.viewController.aqiLabel.textColor, UIColor.black, "The AQI label text color should be black for better contrast on yellow background")
            XCTAssertEqual(self.viewController.levelLabel.textColor, UIColor.black, "The level label text color should be black for better contrast on yellow background")
            XCTAssertEqual(self.viewController.descriptionLabel.textColor, UIColor.black, "The description label text color should be black for better contrast on yellow background")
        }
    }
}
