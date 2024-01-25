//
//  MapModel.swift
//  MapTest
//
//  Created by Владимир  Лукоянов on 25.01.2024.
//

import Foundation
import MapKit

protocol MapModelProtocol {
    var annotaionArray: [MKPointAnnotation] {get set}
    func addAnnotation(_ annotation: MKPointAnnotation)
    func clearAnnotations()
    func geocodeAddress(_ address: String, completion: @escaping (Result<MKPointAnnotation, Error>) -> Void)
    func createRouteRequest(from startCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Result<MKDirections.Response, Error>) -> Void)
}

final class MapModel: MapModelProtocol {
    
    var annotaionArray = [MKPointAnnotation]()
    
    func addAnnotation(_ annotation: MKPointAnnotation) {
        annotaionArray.append(annotation)
        
    }
    
    func clearAnnotations() {
        annotaionArray.removeAll()
    }
    
    func geocodeAddress(_ address: String, completion: @escaping (Result<MKPointAnnotation, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
                
            }
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(.failure(NSError(domain: "MapModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти адрес"])))
                return
                
            }
            let annotation = MKPointAnnotation()
            annotation.title = address
            annotation.coordinate = location.coordinate
            completion(.success(annotation))
            
        }
    }
    
    func createRouteRequest(from startCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Result<MKDirections.Response, Error>) -> Void) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                completion(.failure(error))
                return
                
            }
            guard let response = response else {
                completion(.failure(NSError(domain: "MapModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить ответ на запрос маршрута"])))
                return
                
            }
            completion(.success(response))
            
        }
    }
}
