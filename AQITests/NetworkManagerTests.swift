//
//  NetworkManagerTests.swift
//  AQITests
//
//  Created by Greg Alton on 6/27/24.
//

import XCTest
@testable import AQI

// This is required for testFetchAQIFailure(). I don't like to add code to production for tests, so using an extension in the test target.
extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        default:
            return false
        }
    }
}

class NetworkManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    func testFetchAQISuccess() async {
        let expectedAQIResponse = AQIResponse(status: "ok", data: AQIData(aqi: 50))
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! JSONEncoder().encode(expectedAQIResponse)
            return (response, data)
        }
        
        let result = await NetworkManager().fetchAQI(latitude: 31.6893785, longitude: -85.9607448)
        
        switch result {
        case .success(let aqiResponse):
            XCTAssertEqual(aqiResponse.data.aqi, expectedAQIResponse.data.aqi)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testFetchAQIFailure() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://api.waqi.info")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let result = await NetworkManager().fetchAQI(latitude: 31.6893785, longitude: -85.9607448)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error, .invalidResponse)
        }
    }
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Request handler is not set.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
