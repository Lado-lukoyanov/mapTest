//
//  Alert.swift
//  MapTest
//
//  Created by Владимир  Лукоянов on 09.02.2023.
//

import UIKit

extension UIViewController {
    func alertAddAdress(title: String , placeholder: String, completionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) {(action) in
            
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }
        
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertCansel = UIAlertAction(title: "Отмена", style: .default) {(_) in
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCansel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func allertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
    }
}
