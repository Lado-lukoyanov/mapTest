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
    
    var viewModel = MapViewModel()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraint()
        mapView.delegate = self
        addAdressButton.addTarget(self, action: #selector(addAdressButtonTap), for: .touchUpInside)
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
    
    @objc func addAdressButtonTap() {
           alertAddAdress(title: "Добавить", placeholder: "Введите Адрес") { [unowned self] (text) in
               viewModel.addAnnotation(forAddress: text) { result in
                   switch result {
                   case .success():
                       self.mapView.addAnnotations(self.viewModel.annotations)
                   case .failure(let error):
                       self.allertError(title: "Oшибкa", message: error.localizedDescription)
                       
                   }
               }
           }
       }
    @objc func routeButtonTap() {
        viewModel.createRoute { [unowned self] result in
            switch result {
            case .success(let responses):
                responses.forEach { response in
                    response.routes.forEach { route in
                        self.mapView.addOverlay(route.polyline)
                    }
                }
            case .failure(let error):
                self.allertError(title: "Oшибкa", message: error.localizedDescription)
            }
        }
        
    }
    
    @objc func refreshButtonTap() {
        viewModel.clearAnnotations()
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        routeButton.isHidden = true
        refreshButton.isHidden = true
        
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 4.0
            renderer.strokeColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)


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

