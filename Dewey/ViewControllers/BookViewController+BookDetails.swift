//
//  BookViewController+BookDetails.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-05-01.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import Foundation
import UIKit

extension BookViewController {
    // MARK: Book Details Card Setup
    func setupCard() {
        cardHeight = bookDetailsView.bounds.height - cardTopPadding + cardStretchSection
        bookDetailsViewController = BookDetailsViewController(nibName: "BookDetailsViewController", bundle: nil)
        bookDetailsViewController.book = book
        addChild(bookDetailsViewController)
        bookDetailsView.addSubview(bookDetailsViewController.view)

        bookDetailsViewController.view.frame = CGRect(x: 0,
                                                      y: bookDetailsView.bounds.height - cardMinVisibleHeight,
                                                      width: bookDetailsView.bounds.width,
                                                      height: cardHeight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(gesture:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(gesture:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleCardSwipe(gesture:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleCardSwipe(gesture:)))
        swipeUp.direction = .up
        swipeDown.direction = .down

        bookDetailsViewController.handleArea.addGestureRecognizer(tap)
        bookDetailsViewController.view.addGestureRecognizer(pan)
        bookDetailsViewController.view.addGestureRecognizer(swipeUp)
        bookDetailsViewController.view.addGestureRecognizer(swipeDown)
    }

    // MARK: - Gesture Handlers
    @objc func handleCardTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            toggleBookDetails(state: nextState)
        }
    }
    
    @objc func handleCardSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            toggleBookDetails(state: .collapsed)
        } else if gesture.direction == .up {
            toggleBookDetails(state: .expanded)
        }
    }
    
    @objc func handleCardPan(gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        
        let translation = gesture.translation(in: bookDetailsView)
        let newPosition = gestureView.frame.origin.y + translation.y
        
        // Make sure frame doesn't go past an arbitrary area on the screen
        if newPosition > 10 && newPosition < (bookDetailsView.frame.height - 250) {
            gestureView.frame.origin.y = newPosition
        }
        
        gesture.setTranslation(.zero, in: bookDetailsView)
        
        let inExpandArea: Bool = gestureView.frame.origin.y < (bookDetailsView.frame.height/2 - 20)
        switch gesture.state {
        case .began:
            if !panAnimationQueue.isEmpty {
                for animation in panAnimationQueue {
                    animation.stopAnimation(true)
                }
                panAnimationQueue.removeAll()
                startPanAnimation(state: inExpandArea ? .collapsed : .expanded)
                cardVisible = inExpandArea ? true : false
            } else {
                startPanAnimation(state: nextState)
            }
        case .changed:
            let panZone = bookDetailsView.frame.height - cardMinVisibleHeight - cardTopPadding
            let panPosition = newPosition - cardTopPadding // position relative to the pan zone
            let fractionCompleted = (cardVisible ? panPosition : panZone - panPosition ) / panZone
            updatePanAnimation(fractionCompleted: fractionCompleted)
        case .ended:
            if (inExpandArea && cardVisible) || (!inExpandArea && !cardVisible) {
                for animation in panAnimationQueue {
                    // Reverse pan animation if there will be no changes in card state
                    animation.isReversed = true
                }
            }
            continuePanAnimation()
            animateCard(state: inExpandArea ? .expanded : .collapsed)
        default:
            break
        }
    }
    
    // MARK: - Helper Functions for Gesture Handlers
    func toggleBookDetails(state: CardState, duration: TimeInterval = 0.5) {
        animateCard(state: state, duration: duration)
        animateBookScale(state: state, duration: duration)
    }

    func animateBookScale(state: CardState, duration: TimeInterval) {
        let bookScaleAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.bookCover.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            case .collapsed:
                self.bookCover.transform = .identity
            }
        }
        
        bookScaleAnimator.startAnimation()
        panAnimationQueue.append(bookScaleAnimator)
    }
    
    func animateCard(state: CardState, duration: TimeInterval = 0.5) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.bookDetailsViewController.view.frame.origin.y = self.cardTopPadding
            case .collapsed:
                self.bookDetailsViewController.view.frame.origin.y = self.bookDetailsView.bounds.height - self.cardMinVisibleHeight
            }
        }
        
        frameAnimator.addCompletion {
            _ in
            self.cardVisible = state == .expanded ? true : false
            self.panAnimationQueue.removeAll()
        }
        
        frameAnimator.startAnimation()
        panAnimationQueue.append(frameAnimator)
    }
    
    func startPanAnimation(state: CardState, duration: TimeInterval = 0.5) {
        animateBookScale(state: state, duration: duration)
        
        for animation in panAnimationQueue {
            animation.pauseAnimation()
        }
    }
    
    func updatePanAnimation(fractionCompleted: CGFloat) {
        for animation in panAnimationQueue {
            animation.fractionComplete = fractionCompleted
        }
    }
    
    func continuePanAnimation() {
        for animation in panAnimationQueue {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
