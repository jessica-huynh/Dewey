//
//  UINavigationController+Custom.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-02.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    static func custom(with rootViewController: UIViewController) -> UINavigationController {
        let navController: UINavigationController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.barTintColor = UIColor(hexString: "#EEECE4")
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = UIColor.darkGray
        return navController
    }
}
