//
//  ExplorePageDataSource.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit

internal final class ExploreWordsDataSource: ValueCellDataSource {
    internal enum Section: Int {
        case onboarding
        case words
    }
    
    func load(words: [Word]) {
        self.clearValues(section: Section.words.rawValue)
        
        words.forEach { word in
            self.appendRow(
                value: word,
                cellClass: WordPostcardCell.self,
                toSection: Section.words.rawValue
            )
        }
    }
    
    func show(onboarding: Bool) {
        
    }
    
    internal func wordAtIndexPath(_ indexPath: IndexPath) -> Word? {
        return self[indexPath] as? Word
    }
    
    internal func indexPath(forProjectRow row: Int) -> IndexPath {
        return IndexPath(item: row, section: Section.words.rawValue)
    }
    
    override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
        
        switch (cell, value) {
        case let (cell as WordPostcardCell, value as Word):
            cell.configureWith(value: value)
        default:
            assertionFailure("Unrecognized combo: \(cell), \(value)")
        }
    }
}
