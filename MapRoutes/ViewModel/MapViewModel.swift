//
//  MapViewModel.swift
//  MapRoutes
//
//  Created by Вячеслав Квашнин on 13.08.2021.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    
    @Published var region: MKCoordinateRegion!
    
    @Published var permissionDenied = false
    
    @Published var password = ""
    
    @Published var massiv = [String]()
    
    @Published var annotationsArray = [MKPointAnnotation]()
    
    @Published var showButton = false
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            
            manager.requestLocation()
            
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        self.mapView.setRegion(self.region, animated: true)
        
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    
    func routPin(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        
        direction.calculate { responce, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let responce = responce else { return }
            
            var minRoute = responce.routes[0]
            
            for route in responce.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
//                print(route.distance)
            }
            self.mapView.addOverlay(minRoute.polyline)
            
        }
    }
    
    func routeButton() {
        for index in 0...annotationsArray.count - 2 {
            routPin(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    func alertView(completionHandler: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: "Введите адрес", message: "", preferredStyle: .alert)
        
        alert.addTextField { (pass) in
            pass.placeholder = "Введите адрес..."
        }
        
        let login = UIAlertAction(title: "Ввод", style: .default) { (_) in
            self.password = alert.textFields![0].text!
            completionHandler(self.password)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .destructive) { (_) in }
        
        alert.addAction(cancel)
        alert.addAction(login)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
        })
    }
    
    func mark(addressPlace: String) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addressPlace) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = "\(addressPlace)"
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.annotationsArray.append(annotation)
            
            if self.annotationsArray.count > 2 {
                self.showButton = true
            }
            self.mapView.showAnnotations(self.annotationsArray, animated: true)
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    func deletePin() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationsArray.removeAll()
        showButton = false
    }
}

