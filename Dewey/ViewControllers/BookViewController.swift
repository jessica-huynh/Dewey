//
//  BookViewController.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-26.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
    var book: Book!
    var bookDetailsViewController: BookDetailsViewController!
    
    var cardHeight: CGFloat!
    let cardTopPadding: CGFloat = 70
    let cardStretchSection: CGFloat = 50
    let cardMinVisibleHeight: CGFloat = 300
    var cardVisible = false
    var visualEffectView: UIVisualEffectView!
    var panAnimationQueue: [UIViewPropertyAnimator] = []
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    enum CardState {
        case expanded, collapsed
    }
    
    @IBOutlet weak var bookCover: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        setupBookCover()
        setupCard()
    }
    
    func setupBookCover() {
        let url = URL(string: book.cover)
        bookCover.kf.indicatorType = .activity
        bookCover.kf.setImage(
            with: url,
            placeholder: UIImage(named: "book-cover-placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
    }
    
    func setupCard() {
        cardHeight = self.view.bounds.height - cardTopPadding + cardStretchSection
        bookDetailsViewController = BookDetailsViewController(nibName:"BookDetailsView", bundle:nil)
        addChild(bookDetailsViewController)
        view.addSubview(bookDetailsViewController.view)

        bookDetailsViewController.view.frame = CGRect(x: 0,
                                                      y: view.bounds.height - cardMinVisibleHeight,
                                                      width: view.bounds.width,
                                                      height: cardHeight)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(gesture:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(gesture:)))
        
        bookDetailsViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        bookDetailsViewController.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleCardTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            animateCard(state: nextState, duration: 0.9)
            animateBlur(state: nextState, duration: 0.9)
        }
    }
    
    @objc func handleCardPan(gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        
        let translation = gesture.translation(in: view)
        let newPosition = gestureView.frame.origin.y + translation.y
        
        // Check if the top of the frame doesn't go past an arbitrary area on the screen
        if newPosition > 30 && newPosition < (view.frame.height - 200) {
            gestureView.frame.origin.y = newPosition
        }
        
        gesture.setTranslation(.zero, in: view)
        
        switch gesture.state {
        case .began:
            startPanBlur(state: nextState, duration: 0.9)
        case .changed:
            let panZone = view.frame.height - cardMinVisibleHeight - cardTopPadding
            let panPosition = newPosition - cardTopPadding // position relative to the pan zone
            let fractionCompleted = (cardVisible ? panPosition : panZone - panPosition ) / panZone
            updatePanBlur(fractionCompleted: fractionCompleted)
        case .ended:
            let inExpandArea: Bool = gestureView.frame.origin.y < (view.bounds.height/2 - 30)
            if (inExpandArea && cardVisible) || (!inExpandArea && !cardVisible) {
                for animation in panAnimationQueue {
                    // Reverse blur animation if there will be no changes in card state
                    animation.isReversed = true
                }
            }
            continuePanTransition()
            
            if inExpandArea {
                animateCard(state: .expanded, duration: 0.9)
            } else {
                animateCard(state: .collapsed, duration: 0.9)
            }
        default:
            break
        }
    }
    
    func animateBlur(state: CardState, duration: TimeInterval) {
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.visualEffectView.effect = UIBlurEffect(style: .regular)
            case .collapsed:
                self.visualEffectView.effect = nil
            }
        }
        
        blurAnimator.startAnimation()
        panAnimationQueue.append(blurAnimator)
    }
    
    func animateCard(state: CardState, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.bookDetailsViewController.view.frame.origin.y = self.cardTopPadding
            case .collapsed:
                self.bookDetailsViewController.view.frame.origin.y = self.view.bounds.height - self.cardMinVisibleHeight
            }
        }
        
        frameAnimator.addCompletion {
            _ in
            self.cardVisible = state == .expanded ? true : false
            self.panAnimationQueue.removeAll()
        }
        
        frameAnimator.startAnimation()
    }
    
    func startPanBlur(state: CardState, duration: TimeInterval) {
        animateBlur(state: state, duration: duration)
        
        for animation in panAnimationQueue {
            animation.pauseAnimation()
        }
    }
    
    func updatePanBlur(fractionCompleted: CGFloat) {
        for animation in panAnimationQueue {
            animation.fractionComplete = fractionCompleted
        }
    }
    
    func continuePanTransition() {
        for animation in panAnimationQueue {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
}
 
