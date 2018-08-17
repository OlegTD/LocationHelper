//
//  LocationHelper.swift
//
//  Created by Developer on 07.02.2018.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject {
    typealias LocationCompletion = (_ gpsParameters: [String:String]) -> Void
    static let shared = LocationHelper()
    let locationManager = CLLocationManager()
    var completion: LocationCompletion!
    
    //getting my current location
    func getCurrentLocation(completion: @escaping(LocationCompletion)) {
        self.completion = completion
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        if UIDevice.isSimulator {
            completion(locationToDict(location: CLLocation(latitude: 0.0, longitude: 0.0)))
        }
    }
    
    ///converting locations to dict for API
    private func locationToDict(location: CLLocation) -> [String:String] {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let dictGPS = ["Latitude":String(latitude), "Longitude":String(longitude)]
        return dictGPS
    }
    
    ///check if location services are enabled
    class func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                return true
            }
        } else {
            return false
        }
    }
    
}

extension LocationHelper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        let gpsParameters = locationToDict(location: location)
        completion(gpsParameters)
    }

}
