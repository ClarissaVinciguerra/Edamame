//
//  UIViewController+Extras.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 12/8/20.
//

import UIKit

extension UIViewController {
    func presentAlertController(title: String?, message: String?, preferredStyle: UIAlertController.Style, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        navigationController?.pushViewController(alertController, animated: true)
    }
}
