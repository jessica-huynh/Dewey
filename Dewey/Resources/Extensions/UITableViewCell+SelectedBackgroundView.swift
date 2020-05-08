//
//  UITableViewCell+SelectedBackgroundView.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-08.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    static let darkerBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "#EEECE4").darken(by: 5)
        return backgroundView
    }()
    
    static let clearBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        return backgroundView
    }()
}
