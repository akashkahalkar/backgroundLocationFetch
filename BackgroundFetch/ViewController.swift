//
//  ViewController.swift
//  BackgroundFetch
//
//  Created by akash.kahalkar on 18/07/21.
//

import UIKit
import CoreLocation

struct LocationData {
    var coordinates: String
    var date: Date
}

class ViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    var locationData = [LocationData]() {
        didSet {
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load called")
        checkAuthStatus()
        setupTableView()
    }

    private func checkAuthStatus() {
        let status = CLLocationManager.authorizationStatus()
        requestAuthorization(status)
    }
    
    private func setupManager() {
        //location manager delegate setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
//        if #available(iOS 11.0, *) {
//            locationManager.showsBackgroundLocationIndicator = true
//        }
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    
    func setupTableView () {
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

        //get both times sinces refrenced date and divide by 60 to get minutes
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

        //then return the difference
        return CGFloat(newDateMinutes - oldDateMinutes)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    private func requestAuthorization(_ status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            setupManager()
        @unknown default:
            break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        
        requestAuthorization(status)
    }
    
    private func saveLocation(currentLocation: CLLocation) {
        let coordinate = "lat: \(currentLocation.coordinate.latitude), long: \(currentLocation.coordinate.latitude)"
        let date = Date()
        locationData.append(LocationData(coordinates: coordinate, date: date))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            
            if locationData.isEmpty {
                saveLocation(currentLocation: currentLocation)
            } else {
                if let lastDate = locationData.last?.date, minutesBetweenDates(lastDate, Date()) > 10 {
                   saveLocation(currentLocation: currentLocation)
                }
            }
            //try to defere the delivery of location updates to 500 meters or 10 min
            locationManager.allowDeferredLocationUpdates(
                untilTraveled: CLLocationDistance(500),
                timeout: TimeInterval(600)
            )
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error) {
        
        print("error didFailewithError - ", error.localizedDescription)
        print("faild to update location")
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
        print("error didFinishDeferredUpdatesWithError - ", error.debugDescription)
        print("locations defered")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationData.count > 0 ? locationData.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        
        if locationData.count > 0 && locationData.indices.contains(indexPath.row) {
            
            cell.textLabel?.text = self.locationData[indexPath.row].coordinates
            cell.detailTextLabel?.text = self.locationData[indexPath.row].date.description
        } else {
            cell.textLabel?.text = "No location data"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
