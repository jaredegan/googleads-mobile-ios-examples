//
//  IssueReproduction.swift
//  DFPBannerExample
//
//  Created by Jared Egan on 6/20/18.
//

import UIKit
import CoreLocation
import UserNotifications

class IssueReproduction: NSObject, CLLocationManagerDelegate {
    static let instance = IssueReproduction()

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    var logMessage: String = ""

    override init() {
        super.init()

        locationManager.distanceFilter = 200
        locationManager.delegate = self
    }

    func log(_ message: String) {
        logMessage = "\(logMessage)\n\(message)"
    }

    func startUpdating() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .authorizedAlways ||
            authStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func stopUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func askForNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func askForLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Mimics geofences created by our Partner SDKs
    func createGeofence() {
        guard let location = lastLocation else { return }

        let region = CLCircularRegion(
            center: location.coordinate,
            radius: 400,
            identifier: "test")

        locationManager.startMonitoring(for: region)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // No error handling for test app
        startUpdating()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        fireNotification(title: "Exit", body: "Region exit")

        // Move the geo fence
        manager.stopMonitoring(for: region)
        createGeofence()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last

        if locationManager.monitoredRegions.count == 0 {
            createGeofence()
        }

    }


    func fireNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "TEST"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger)

        fireLocalNotification(request)
    }

    func fireLocalNotification(_ notification: UNNotificationRequest) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.fireLocalNotification(notification)
            }
            return
        }

        UNUserNotificationCenter.current().add(notification) { (error: Error?) in
            if let theError = error {
                print("Couldn't schedule notification: " + theError.localizedDescription)
            } else {
                print("Successfully scheduled local notification!")
            }
        }
    }
}
