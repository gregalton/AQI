//
//  ViewController.swift
//  AQI
//
//  Created by Greg Alton on 6/26/24.
//

import UIKit
import CoreLocation

struct AQIInfo {
    let aqi: Int
    let level: String
    let description: String
    let backgroundColor: UIColor
}

class ViewController: UIViewController, LocationManagerDelegate {
    var locationManager: LocationManager?
    private let networkManager: NetworkManager
    
    let aqiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let levelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.networkManager = NetworkManager()
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    private func setupLocationManager() {
        locationManager = LocationManager()
        locationManager?.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(aqiLabel)
        view.addSubview(levelLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            aqiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aqiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            aqiLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            levelLabel.topAnchor.constraint(equalTo: aqiLabel.bottomAnchor, constant: 16),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            descriptionLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
    }
    
    private func handleAQIResult(_ result: Result<AQIResponse, NetworkError>) {
        switch result {
        case .success(let aqiResponse):
            let aqiInfo = getAQIInfo(for: aqiResponse.data.aqi)
            updateUI(with: aqiInfo)
        case .failure:
            showAlert(message: "Error fetching Air Quality Index")
        }
    }
    
    private func getAQIInfo(for aqi: Int) -> AQIInfo {
        switch aqi {
        case 0...50:
            return AQIInfo(aqi: aqi, level: "Good", description: "Air quality is considered satisfactory, and air pollution poses little or no risk.", backgroundColor: .systemGreen)
        case 51...100:
            return AQIInfo(aqi: aqi, level: "Moderate", description: "Air quality is acceptable; however, some pollutants may be a concern for a small number of people.", backgroundColor: .systemYellow)
        case 101...150:
            return AQIInfo(aqi: aqi, level: "Unhealthy for Sensitive Groups", description: "Members of sensitive groups may experience health effects. The general public is less likely to be affected.", backgroundColor: .systemOrange)
        case 151...200:
            return AQIInfo(aqi: aqi, level: "Unhealthy", description: "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.", backgroundColor: .systemRed)
        case 201...300:
            return AQIInfo(aqi: aqi, level: "Very Unhealthy", description: "Health alert: everyone may experience more serious health effects.", backgroundColor: .systemPurple)
        case 301...500:
            return AQIInfo(aqi: aqi, level: "Hazardous", description: "Health warning of emergency conditions: everyone is more likely to be affected.", backgroundColor: .black)
        default:
            return AQIInfo(aqi: aqi, level: "Unknown", description: "Air quality data is not available.", backgroundColor: .systemGray)
        }
    }
    
    private func updateUI(with aqiInfo: AQIInfo) {
        DispatchQueue.main.async {
            self.view.backgroundColor = aqiInfo.backgroundColor
            self.aqiLabel.textColor = .white
            self.levelLabel.textColor = .white
            self.descriptionLabel.textColor = .white
            self.aqiLabel.text = "\(aqiInfo.aqi)"
            self.levelLabel.text = aqiInfo.level
            self.descriptionLabel.text = aqiInfo.description
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    //MARK: - LocationManager Delegates
    func didChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            // Handle denied or restricted status
            showAlert(message: "Location access denied or restricted.")
        default:
            break
        }
    }
    
    func didUpdateLocation(_ location: CLLocation) {
        Task {
            let result = await networkManager.fetchAQI(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            handleAQIResult(result)
        }
    }
    
    func didFailWithError(_ error: Error) {
        showAlert(message: "Error getting your location")
    }

}

