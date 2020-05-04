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
        cardHeight = view.bounds.height - cardPadding + cardStretchSection
        cardExpandedY = cardPadding
        cardCollapsedY = bookCover.frame.origin.y + bookCover.bounds.height + cardPadding
        
        bookDetailsViewController = BookDetailsViewController(nibName: "BookDetailsViewController", bundle: nil)
        bookDetailsViewController.book = book
        addChild(bookDetailsViewController)
        view.addSubview(bookDetailsViewController.view)

        bookDetailsViewController.view.frame = CGRect(x: 0,
                                                      y: cardCollapsedY,
                                                      width: view.bounds.width,
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
        
        let translation = gesture.translation(in: view)
        let newPosition = gestureView.frame.origin.y + translation.y
        
        // Make sure frame doesn't go past an arbitrary area on the screen
        if newPosition > (cardExpandedY - 30) && newPosition < (cardCollapsedY + 30) {
            gestureView.frame.origin.y = newPosition
        }
        
        gesture.setTranslation(.zero, in: view)
        
        let inExpandArea: Bool = gestureView.frame.origin.y < (view.bounds.height/2 - 60)
        switch gesture.state {
        case .began:
            if !panAnimationQueue.isEmpty {
                for animation in panAnimationQueue {
                    animation.stopAnimation(true)
                }
                panAnimationQueue.removeAll()
                startPanAnimation(state: inExpandArea ? .collapsed : .expanded)
                isCardVisible = inExpandArea ? true : false
            } else {
                startPanAnimation(state: nextState)
            }
        case .changed:
            let panZone = cardCollapsedY - cardExpandedY
            let panPosition = newPosition - cardExpandedY // position relative to the pan zone
            let fractionCompleted = (isCardVisible ? panPosition : panZone - panPosition ) / panZone
            updatePanAnimation(fractionCompleted: fractionCompleted)
        case .ended:
            if (inExpandArea && isCardVisible) || (!inExpandArea && !isCardVisible) {
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
                self.bookDetailsViewController.view.frame.origin.y = self.cardExpandedY
            case .collapsed:
                self.bookDetailsViewController.view.frame.origin.y = self.cardCollapsedY
            }
        }
        
        frameAnimator.addCompletion {
            _ in
            self.isCardVisible = state == .expanded ? true : false
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
