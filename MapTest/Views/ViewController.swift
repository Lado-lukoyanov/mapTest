//
//  ViewController.swift
//  MapTest
//
//  Created by Владимир  Лукоянов on 31.01.2023.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAdressButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "adressButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "routeButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let refreshButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "refreshButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotaionArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraint()
        mapView.delegate = self
        addAdressButton.addTarget(self, action: #selector(addAdressbuttonTap), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTap), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTap), for: .touchUpInside)

    }
    
    private func setupViews() {
        view.backgroundColor = .none
        
        view.addSubview(mapView)
        mapView.addSubview(addAdressButton)
        mapView.addSubview(refreshButton)
        mapView.addSubview(routeButton)
    }
    
    @objc func addAdressbuttonTap() {
        alertAddAdress(title: "Добавить", placeholder: "Ввидите Адрес") { [self] (text) in
            setupPlacemark(addresPlace: text)
        }
    }
    
    @objc func routeButtonTap() {
        
        for index in 0...annotaionArray.count - 2 {
            createDirectionRequst(startCoordinate: annotaionArray[index].coordinate, destinationCoodrinate: annotaionArray[index + 1].coordinate)
        }
        
        mapView.showAnnotations(annotaionArray, animated: true)
        
    }
    
    @objc func refreshButtonTap() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotaionArray = [MKPointAnnotation]()
        routeButton.isHidden = true
        refreshButton.isHidden = true
    }
    
    private func setupPlacemark(addresPlace: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addresPlace) { [self] (placemarks, error) in
            
            if let error = error {
                print(error)
                allertError(title: "Error", message: "Not Found")
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(addresPlace)"
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotaionArray.append(annotation)
            
            if annotaionArray.count > 2 {
                routeButton.isHidden = false
                refreshButton.isHidden = false
            }
            
            mapView.showAnnotations(annotaionArray, animated: true)
        }
    }
    
    private func createDirectionRequst(startCoordinate: CLLocationCoordinate2D, destinationCoodrinate: CLLocationCoordinate2D){
        
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoodrinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let  response = response else {
                self.allertError(title: "Error", message: "Not Found")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        return render
    }
}

extension ViewController {
    
    func setConstraint() {
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            addAdressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            addAdressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            addAdressButton.heightAnchor.constraint(equalToConstant: 80),
            addAdressButton.widthAnchor.constraint(equalToConstant: 80),
            
            routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            routeButton.heightAnchor.constraint(equalToConstant: 80),
            routeButton.widthAnchor.constraint(equalToConstant: 80),
            
            refreshButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            refreshButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            refreshButton.heightAnchor.constraint(equalToConstant: 80),
            refreshButton.widthAnchor.constraint(equalToConstant: 80)
            
        ])
    }
}
