//
//  BookViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit
import AVFoundation

class BookViewController: UIViewController, BookshelfOptionsViewControllerDelegate {
    let storageManager = StorageManager.instance
    var book: Book!
    var originatingBookshelf: Bookshelf?
    
    var didEditBookshelves = false
    var bookDetailsViewController: BookDetailsViewController!
    var finalBookCoverFrame: CGRect!
    var bookCoverDropShadow: UIView!
    
    var spinnerView: UIView!
    var isLoading: Bool = true
    
    var cardHeight: CGFloat!
    let cardPadding: CGFloat = 40
    let cardStretchSection: CGFloat = 50
    var cardExpandedY: CGFloat!
    var cardCollapsedY: CGFloat!
    var isCardSetup = false
    var wasCardSetupStarted = false
    var wasCardPresented = false
    var isCardExpanded = false
    
    var panAnimationQueue: [UIViewPropertyAnimator] = []
    
    enum CardState {
        case expanded, collapsed
    }
    
    @IBOutlet weak var bookCover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if navigationController?.viewControllers.first == self {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(backTapped))
            navigationItem.setLeftBarButton(closeButton, animated: true)
        }
        
        spinnerView = createSpinnerView(with: UIColor(hexString: "#EEECE4"))
        showSpinner(spinnerView: spinnerView)
        setupBackground()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !wasCardSetupStarted {
            // Setup card after book cover is loaded so we can determine the collapsed
            // Y position of the card based on the book cover height
            setupBookCover(completionHandler: { self.setupCard() })
            self.wasCardSetupStarted = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#EEECE4")
        
        if didEditBookshelves {
            NotificationCenter.default.post(name: .updatedBookshelves, object: self)
        }
        
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Setup Helpers
    func setupBackground() {
        if let dominantColour = book.dominantColour {
            addBackgroundGradient(with: UIColor(hexString: dominantColour))
        } else if !book.coverLarge.isEmpty {
            if let dominantColour = storageManager.getDominantColour(for: book) {
                addBackgroundGradient(with: UIColor(hexString: dominantColour))
                endBackgroundSetup()
                return
            }
            
            SightEngineAPI.request(for: .analyzeImage(url: book.coverLarge)) {
                [weak self] response in
                guard let self = self else { return }
                
                let analyzeImageResponse = try AnalyzeImageResponse(data: response.data)
                let dominantColour = analyzeImageResponse.colourAnalysis.dominantColour
                
                self.addBackgroundGradient(with: UIColor(hexString: dominantColour.hex))
                self.book.dominantColour = dominantColour.hex
                
                if self.storageManager.bookIsInAShelf(book: self.book) {
                    self.storageManager.updateDominantColour(for: self.book,
                                                             with: dominantColour.hex)
                }
                
                self.endBackgroundSetup()
            }
            return
        }
        endBackgroundSetup()
    }
    
    func endBackgroundSetup() {
        removeSpinner(spinnerView: spinnerView)
        isLoading = false
        
        if !wasCardPresented && isCardSetup {
            wasCardPresented = true
            presentCard()
        }
    }
    
    func addBackgroundGradient(with colour: UIColor) {
        let backgroundColour = colour.isLight()! ? colour.darken(by: 10) : colour.lighten(by: 10)
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [backgroundColour.cgColor, UIColor.white.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
        
        let barButtonColour = colour.isLight()! ? colour.darken(by: 40) : colour.lighten(by: 40)
        navigationController?.navigationBar.barTintColor = backgroundColour
        navigationItem.leftBarButtonItem?.tintColor = barButtonColour
        navigationItem.rightBarButtonItem?.tintColor = barButtonColour
        
        if !colour.isLight()! {
            self.navigationController?.navigationBar.barStyle = .black
        }
    }
    
    func setupBookCover(completionHandler: @escaping () -> Void) {
        let url = URL(string: book.coverLarge)
        bookCover.kf.indicatorType = .activity
        bookCover.kf.setImage(
            with: url,
            placeholder: UIImage(named: "book-cover-placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
        ]) {
            result in
            var bookCoverAspectRatio: CGSize!
            switch result {
            case .success(let value):
                bookCoverAspectRatio = CGSize(width: value.image.size.width, height: value.image.size.height)
            case .failure(_):
                bookCoverAspectRatio = UIImage(named: "book-cover-placeholder")!.size
            }
            self.finalBookCoverFrame = AVMakeRect(aspectRatio: bookCoverAspectRatio,
                                                  insideRect: self.bookCover.frame)
            self.addBookDropShadow()
            completionHandler()
        }
    }
    
    func addBookDropShadow() {
        bookCoverDropShadow = UIView(frame: finalBookCoverFrame)
        bookCoverDropShadow.addDropShadow()
        view.insertSubview(bookCoverDropShadow , belowSubview: bookCover)
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        dismissSelf()
    }
    
    @IBAction func showActions(_ sender: Any) {
        let actions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actions.view.tintColor = .darkGray
        
        actions.addAction(UIAlertAction(title: "Add To A Bookshelf", style: .default) {
            _ in
            self.presentBookshelfOptionsViewController()
        })
        
        if let originatingBookshelf = originatingBookshelf {
            actions.addAction(UIAlertAction(title: "Delete From \(originatingBookshelf.name)", style: .default) {
                _ in
                self.storageManager.removeBook(book: self.book, from: originatingBookshelf)
                self.didEditBookshelves = true
                self.dismissAfterBookDeletedIfNeeded()
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
        alert.view.tintColor = .darkGray
        let deleteAction = UIAlertAction(title: "Yes", style: .default) {
            _ in
            self.storageManager.removeBookEverywhere(book: self.book)
            self.didEditBookshelves = true
            self.dismissAfterBookDeletedIfNeeded()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func dismissAfterBookDeletedIfNeeded() {
        if let _ = self.navigationController?.presentingViewController as? SearchResultsViewController {
            // View controller does not need to be dismissed if `book` was assigned from
            // an instance of Book that will not be empty after deletion (e.g. when
            // coming from the search results page)
            ConfirmationHudView.present(inView: self.navigationController!.view, animated: true)
        } else {
            dismissSelf()
        }
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
        ConfirmationHudView.present(inView: self.navigationController!.view, animated: true)
    }
}
