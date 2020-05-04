//
//  BookViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, BookshelfOptionsViewControllerDelegate {
    let storageManager = StorageManager.instance
    var book: Book!
    var bookDetailsViewController: BookDetailsViewController!
    var originatingBookshelf: Bookshelf?
    var didEditBookshelves = false
    var spinnerView: UIView!
    
    var cardHeight: CGFloat!
    let cardTopPadding: CGFloat = 40
    let cardStretchSection: CGFloat = 50
    let cardMinVisibleHeight: CGFloat = 300
    var isCardSetup = false
    var isCardVisible = false
    var panAnimationQueue: [UIViewPropertyAnimator] = []
    var nextState: CardState {
        return isCardVisible ? .collapsed : .expanded
    }
    
    enum CardState {
        case expanded, collapsed
    }
    
    @IBOutlet weak var bookCover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerView = createSpinnerView(with: UIColor(hexString: "#EEECE4"))
        //showSpinner(spinnerView: spinnerView)
        setupBookCover()
        //setupBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backTapped))
            navigationItem.setLeftBarButton(closeButton, animated: true)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !isCardSetup {
            setupCard()
            isCardSetup = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#EEECE4")
        
        if didEditBookshelves {
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
    }
    
    // MARK: - Setup Helpers
    func setupBackground() {
        if book.coverLarge.isEmpty {
            removeSpinner(spinnerView: self.spinnerView)
            return
        }
        
        SightEngineAPI.request(for: .analyzeImage(url: book.coverLarge)) {
            [weak self] response in
            guard let self = self else { return }
            
            let analyzeImageResponse = try AnalyzeImageResponse(data: response.data)
            let dominantColour = analyzeImageResponse.colourAnalysis.dominantColour
            
            if dominantColour.hex != "#ffffff" {
                self.addBackgroundGradient(with: UIColor(hexString: dominantColour.hex).lighten(by: 10))
            }
            self.removeSpinner(spinnerView: self.spinnerView)
        }
    }
    
    func addBackgroundGradient(with colour: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [colour.cgColor, UIColor.white.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
        
        navigationController?.navigationBar.barTintColor = colour
        navigationItem.leftBarButtonItem?.tintColor = colour.lighten(by: 50)
        navigationItem.rightBarButtonItem?.tintColor = colour.lighten(by: 50)
    }
    
    func setupBookCover() {
        let url = URL(string: book.coverLarge)
        bookCover.kf.indicatorType = .activity
        bookCover.kf.setImage(
            with: url,
            placeholder: UIImage(named: "book-cover-placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        bookCover.dropShadow()
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func showActions(_ sender: Any) {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actions.addAction(UIAlertAction(title: "Add To A Bookshelf", style: .default) {
            _ in
            self.presentBookshelfOptionsViewController()
        })
        
        if let originatingBookshelf = originatingBookshelf {
            actions.addAction(UIAlertAction(title: "Delete From \(originatingBookshelf.name)", style: .default) {
                _ in
                self.storageManager.removeBook(book: self.book, from: originatingBookshelf)
                self.didEditBookshelves = true
            })
        }
        
        if storageManager.bookIsInAShelf(book: book) {
            actions.addAction(UIAlertAction(title: "Delete Everywhere", style: .destructive) {
                _ in
                self.showDeleteConfirmation()
            })
        }
        
        actions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actions, animated: true)
    }
    
    // MARK: - Misc Helpers
    func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Delete Everywhere",
                                      message: "Are you sure you want to remove this book from \(storageManager.numberOfBookshelves(with: book)) bookshelves.",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            self.storageManager.removeBookEverywhere(book: self.book)
            self.didEditBookshelves = true
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func presentBookshelfOptionsViewController() {
        let bookshelfOptionsViewController = BookshelfOptionsViewController()
        bookshelfOptionsViewController.delegate = self
        bookshelfOptionsViewController.bookshelfToDisable = originatingBookshelf
        bookshelfOptionsViewController.title = "Add To A Bookshelf"
        
        present(UINavigationController.custom(with: bookshelfOptionsViewController), animated: true, completion: nil)
    }
    
    // MARK: - Book Options Delegate
    func bookshelfOptionsViewController(_ controller: BookshelfOptionsViewController, didSelectBookshelfAt index: Int) {
        let bookshelf = StorageManager.instance.bookshelves[index]
        controller.dismiss(animated: true, completion: nil)
        storageManager.addBook(book: book, to: bookshelf)
        didEditBookshelves = true
    }
}
