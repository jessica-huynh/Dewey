//
//  HomeHeaderTableViewCell.swift
//  Dewey
//
//  Created by Jessica Huynh on 2020-04-25.
//  Copyright © 2020 Jessica Huynh. All rights reserved.
//

import UIKit

class HomeHeaderTableViewCell: UITableViewCell {
    var searchBarDelegate: UISearchBarDelegate? {
        didSet {
            searchBar.delegate = searchBarDelegate
        }
    }
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        header.alpha = 0
        UIView.animate(
            withDuration: 1,
            delay: 0.2, options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.header.alpha = 1 },
            completion: nil)
    }
}
