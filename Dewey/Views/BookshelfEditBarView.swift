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
    
    enum SelectMode {
        case selectAll, deselectAll
        
        var systemImage: UIImage {
            switch self {
            case .selectAll:
                return UIImage(systemName: "checkmark.circle")!
            case .deselectAll:
                return UIImage(systemName: "x.circle")!
            }
        }
    }
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    
    func enableActions() {
        moveButton.isEnabled = true
        addButton.isEnabled = true
        deleteButton.isEnabled = true
    }
    
    func disableActions() {
        moveButton.isEnabled = false
        addButton.isEnabled = false
        deleteButton.isEnabled = false
    }
    
    func enableSelectAllButton() {
        selectAllButton.isEnabled = true
    }
    
    func disableSelectAllButton() {
        selectAllButton.isEnabled = false
    }
    
    func switchSelectAllButton(to mode: SelectMode) {
        selectAllButton.setBackgroundImage(mode.systemImage, for: .normal)
    }
}

protocol BookshelfEditBarViewDelegate: class {
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapSelectAll button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapMove button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapAdd button: UIButton)
    func bookshelfEditBarView(_ view: BookshelfEditBarView, didTapDelete button: UIButton)
}
