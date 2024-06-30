//
//  NetworkManager.swift
//  AQI
//
//  Created by Greg Alton on 6/27/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case unknown
}

struct AQIResponse: Codable {
    let status: String
    let data: AQIData
}

struct AQIData: Codable {
    let aqi: Int
}

class NetworkManager {
    private let token = "3d4166dda9447ad124f74e772dcbc1685dada8b5"
    
    func fetchAQI(latitude: Double, longitude: Double) async -> Result<AQIResponse, NetworkError>  {
        let urlString = "https://api.waqi.info/feed/geo:\(latitude);\(longitude)/?token=3d4166dda9447ad124f74e772dcbc1685dada8b5"
        
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let aqiResponse = try JSONDecoder().decode(AQIResponse.self, from: data)
            return .success(aqiResponse)
        } catch {
            if let error = error as? URLError {
                return .failure(.requestFailed(error))
            } else if let error = error as? DecodingError {
                return .failure(.decodingError(error))
            } else {
                return .failure(.unknown)
            }
        }
    }
}
