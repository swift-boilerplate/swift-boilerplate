//
//  WordPostcardCellViewModel.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public struct WordMetadataData {
    public let iconImage: UIImage?
}

private enum WordMetadataType {
    case new
    case free
    case pro
    case sooner
    
    fileprivate func data(forword word: Word) -> WordMetadataData? {
        switch self {
        case .new:
            return WordMetadataData(iconImage: UIImage(named: "icon_word_new"))
        default:
            return WordMetadataData(iconImage: UIImage(named: "icon_word_empty"))
        }
    }
}

public protocol WordPostcardCellViewModelInputs {
    /// Call to configure cell with activity value.
    func configureWith(word: Word)
    
    /// Call when the see all activity button is tapped.
    func seeAllWordTapped()
}

public protocol WordPostcardCellViewModelOutputs {
    
    /// Emits the text to be put into the word name
}

public protocol WordPostcardCellViewModelType {
    var inputs: WordPostcardCellViewModelInputs { get }
    var outputs: WordPostcardCellViewModelOutputs { get }
}

public final class WordPostcardCellViewModel: WordPostcardCellViewModelInputs,
WordPostcardCellViewModelOutputs, WordPostcardCellViewModelType {
    
    public init() {
        let word = self.wordProperty.signal.skipNil()
    }
    
    fileprivate let wordProperty = MutableProperty<Word?>(nil)
    public func configureWith(word: Word) {
        self.wordProperty.value = word
    }
    
    fileprivate let seeAllWordTappedProperty = MutableProperty()
    public func seeAllWordTapped() {
        self.seeAllWordTappedProperty.value = ()
    }
    
    public var inputs: WordPostcardCellViewModelInputs { return self }
    public var outputs: WordPostcardCellViewModelOutputs { return self }
}

