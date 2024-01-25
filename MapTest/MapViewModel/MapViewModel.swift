//
//  MapViewModel.swift
//  MapTest
//
//  Created by Владимир  Лукоянов on 25.01.2024.
//

import Foundation
import MapKit

class MapViewModel {
    private let model = MapModel()

    // Получение аннотаций
    var annotations: [MKPointAnnotation] {
        return model.annotaionArray
    }

    // Добавление аннотации
    func addAnnotation(forAddress address: String, completion: @escaping (Result<Void, Error>) -> Void) {
        model.geocodeAddress(address) { [weak self] result in
            switch result {
            case .success(let annotation):
                self?.model.addAnnotation(annotation)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func clearAnnotations() {
        model.clearAnnotations()
    }

    func createRoute(completion: @escaping (Result<[MKDirections.Response], Error>) -> Void) {
        var responses: [MKDirections.Response] = []
        let annotations = model.annotaionArray

        let group = DispatchGroup()

        for i in 0..<annotations.count - 1 {
            group.enter()
            let start = annotations[i].coordinate
            let destination = annotations[i + 1].coordinate

            model.createRouteRequest(from: start, to: destination) { result in
                switch result {
                case .success(let response):
                    responses.append(response)
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(.success(responses))
        }
    }
}
