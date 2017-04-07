//
//  WordPostcardCell.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit
import Prelude

internal protocol WordPostcardCellDelegate: class {
    
}

internal final class WordPostcardCell: UITableViewCell, ValueCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var wordSwordView: UIStackView!
    @IBOutlet weak var wordLevelLabel: UILabel!
    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordIconImageView: UIImageView!
    
    fileprivate let viewModel: WordPostcardCellViewModelType = WordPostcardCellViewModel()
    internal weak var delegate: WordPostcardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal override func bindStyles() {
        super.bindStyles()
        
    }
    
    internal override func bindViewModel() {
        super.bindViewModel()
        
    }
    
    internal func configureWith(value: Word) {
        self.viewModel.inputs.configureWith(word: value)
    }
    
}
