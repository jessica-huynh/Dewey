//
//  UIViewController+SpinnerView.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func createSpinnerView(at position: CGPoint? = nil, with backgroundColour: UIColor = .white) -> UIView {
        let spinnerView = UIView(frame: self.bounds)
        spinnerView.backgroundColor = backgroundColour
        let spinner = UIActivityIndicatorView.init(style: .medium)
        spinner.startAnimating()
        spinner.center = position ?? spinnerView.center
        spinnerView.addSubview(spinner)
        return spinnerView
    }
    
    func showSpinner(spinnerView: UIView) {
        self.addSubview(spinnerView)
    }
    
    func removeSpinner(spinnerView: UIView) {
        spinnerView.removeFromSuperview()
    }
}

extension UIViewController {
    func createSpinnerView(at position: CGPoint? = nil, with backgroundColour: UIColor = .white) -> UIView {
        return view.createSpinnerView(at: position, with: backgroundColour)
    }
    
    func showSpinner(spinnerView: UIView) {
        if let navigationController = navigationController {
            navigationController.view.insertSubview(spinnerView, belowSubview: navigationController.navigationBar)
        } else {
            view.showSpinner(spinnerView: spinnerView)
        }
    }
    
    func removeSpinner(spinnerView: UIView) {
        view.removeSpinner(spinnerView: spinnerView)
    }
}
