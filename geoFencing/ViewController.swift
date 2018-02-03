//
//  ViewController.swift
//  geoFencing
//
//  Created by Tianyi Zhang on 2018-01-21.
//  Copyright © 2018 Tianyi Zhang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications


class ViewController: UIViewController  {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000

    
    override func viewDidLoad() {
        super.viewDidLoad()
          UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
        
        locationManager.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        
//        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    func zoomMapOn(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @IBAction func addRegion(_ sender: Any) {
        guard let longPress = sender as? UILongPressGestureRecognizer else { return }
        longPress.minimumPressDuration = 1.0;
        let touchLocation = longPress.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default()
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print ("start monitueing")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
        if let location = locations.last {
            zoomMapOn(location: location)
            mapView.showsUserLocation = true
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "You Entered the Region"
        let message = "Wow theres cool stuff in here! YAY!"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
        print("entered")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let title = "You Left the Region"
        let message = "Say bye bye to all that cool stuff. =["
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
        print("exitted")
    }
}


extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .red
        circleRenderer.fillColor = .red
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}












