//
//  UIViewController+Dismiss.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-04.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    @objc func dismissSelf() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
