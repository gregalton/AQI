//
//  SplashViewController.swift
//  AQI
//
//  Created by Greg Alton on 6/28/24.
//

import UIKit
import CoreLocation

class SplashViewController: UIViewController, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white  // Customize to match your launch screen
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func transitionToMainViewController(with location: CLLocation) {
        let networkManager = NetworkManager()
        Task {
            let result = await networkManager.fetchAQI(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    
            let viewController = ViewController(networkManager: networkManager, location: location, result: result)
                
            // Ensure this is on the main thread
            DispatchQueue.main.async {
                if let navigationController = self.navigationController {
                    UIView.transition(with: navigationController.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        navigationController.setViewControllers([viewController], animated: false)
                    }, completion: nil)
                }
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.global(qos: .background).async {
                self.locationManager.requestLocation()
            }
        case .denied, .restricted:
            // Handle denied or restricted status
            showAlert(message: "Location access denied or restricted.")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location found: \(location)")
            self.location = location
            transitionToMainViewController(with: location)
        } else {
            print("No location found.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        // Handle error (e.g., show an alert)
        showAlert(message: "Error getting your location.")
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
}
