//
//  String+AttributedString.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-03.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func toAttributedString(with font: UIFont, colour: UIColor = UIColor.black, lineSpacing: CGFloat = 0) -> NSAttributedString? {
        guard let data = data(using: String.Encoding.utf8) else { return nil }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacingBefore = lineSpacing/2
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                         .foregroundColor: colour,
                                                         .paragraphStyle: paragraphStyle]
        if let attributedString =
            try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil) {
        attributedString.addAttributes(attributes,
                                       range: NSRange(location: 0,
                                                      length: attributedString.length))
        return attributedString
        }
        return nil
    }
}
