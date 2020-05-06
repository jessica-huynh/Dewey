//
//  ConfirmationHudView.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-06.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationHudView: UIView {
    class func present(inView view: UIView, animated: Bool) {
        let hudView = ConfirmationHudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 100
        let boxHeight: CGFloat = 100
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor.darkGray.setFill()
        roundedRect.fill()
        
        let image = UIImage(systemName: "checkmark.circle")!.withTintColor(.white)
        let imagePoint = CGPoint(x: center.x - round(60 / 2), y: center.y - round(60 / 2))
        image.draw(in: CGRect(x: imagePoint.x, y: imagePoint.y, width: 60, height: 60))
    }
    
    // MARK:- Public methods
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 0.6
                self.transform = CGAffineTransform.identity
            }) { _ in
                self.hide()
            }
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
