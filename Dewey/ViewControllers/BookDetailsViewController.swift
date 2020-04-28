//
//  BookDetailsViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookDetailsViewController: UIViewController {
    var book: Book!
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var genre: UIButton!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var ratingCount: UILabel!
    @IBOutlet weak var bookDescription: UILabel!
    @IBOutlet weak var isbn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        
        genre.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        genre.isUserInteractionEnabled = false
        genre.layer.cornerRadius = 10
        genre.layer.masksToBounds = true
        genre.layer.borderColor = genre.currentTitleColor.cgColor
        genre.layer.borderWidth = 1.0
        
        setupBookDetails()
    }
    
    func setupBookDetails() {
        bookTitle.text = book.title
        author.text = book.author
        bookDescription.text = book.description
        isbn.text = book.isbn
    }
    
    @IBAction func previewTapped(_ sender: Any) {
    }
}
