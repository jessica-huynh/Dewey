//
//  UIViewController+TapToHideKeyboard.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-01.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addTapToResignFirstResponder(with action: Selector = #selector(signalResignFirstResponder)) {
        let tap = UITapGestureRecognizer(target: self, action: action)
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func signalResignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
