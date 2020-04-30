//
//  BookshelfEditBarView.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-29.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class BookshelfEditBarView: UIView {
    var delegate: BookshelfEditBarViewDelegate?
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var selectAllButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("BookshelfEditBarView", owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
    }
    
    @IBAction func selectAllTapped(_ sender: UIButton) {
        delegate?.bookshelfEditBarView(self, didTapSelectAll: sender)
    }
    
    @IBAction func moveBooksTapped(_ sender: UIButton) {
        delegate?.bookshelfEditBarView(self, didTapMove: sender)
    }
    
    
    @IBAction func addBooksTapped(_ sender: UIButton) {
        delegate?.bookshelfEditBarView(self, didTapAdd: sender)
    }
    
    @IBAction func deleteBooksTapped(_ sender: UIButton) {
        delegate?.bookshelfEditBarView(self, didTapDelete: sender)
    }
}

protocol BookshelfEditBarViewDelegate: class {
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapSelectAll button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapMove button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapAdd button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapDelete button: UIButton)
}
