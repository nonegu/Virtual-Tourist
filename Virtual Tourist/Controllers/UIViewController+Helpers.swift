//
//  UIViewController+Helpers.swift
//  Virtual Tourist
//
//  Created by Ender Güzel on 4.09.2019.
//  Copyright © 2019 Creyto. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Alerts
    func presentError(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}
