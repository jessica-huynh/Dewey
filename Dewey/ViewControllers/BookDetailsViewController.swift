//
//  BookDetailsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import Cosmos

class BookDetailsViewController: UIViewController {
    var book: Book!
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var ratingsView: CosmosView!
    @IBOutlet weak var bookDescription: UILabel!
    
    @IBOutlet weak var openButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        ratingsView.settings.fillMode = .precise
        
        openButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        openButton.layer.cornerRadius = 15
        openButton.layer.masksToBounds = true
        openButton.layer.borderColor = UIColor.clear.cgColor
        openButton.layer.borderWidth = 1.0
        
        setupBookDetails()
    }
    
    func setupBookDetails() {
        bookTitle.text = book.title
        author.text = book.author
        bookDescription.attributedText = book.description.toAttributedString(with: UIFont.systemFont(ofSize: 16), colour: UIColor.systemGray, lineSpacing: 10)
        bookDescription.lineBreakMode = .byTruncatingTail
        ratingsView.rating = book.averageUserRating ?? 0
        ratingsView.text = book.userRatingCount != nil ? "\(book.userRatingCount!) ratings" : "No ratings yet"
    }
    
    @IBAction func openTapped(_ sender: Any) {
    }
}
