//
//  MockNetworkManager.swift
//  AQITests
//
//  Created by Greg Alton on 6/27/24.
//

import Foundation
@testable import AQI

class MockNetworkManager: NetworkManager {
    var fetchAQICalled = false
    var mockResult: Result<AQIResponse, NetworkError>?
    
    init(mockResult: Result<AQIResponse, NetworkError>?) {
        self.mockResult = mockResult
        super.init()
    }
    
    override func fetchAQI(latitude: Double, longitude: Double) async -> Result<AQIResponse, NetworkError> {
        fetchAQICalled = true
        if let result = mockResult {
            return result
        }
        return .failure(.requestFailed(NSError(domain: "TestError", code: 1, userInfo: nil)))
    }
}
