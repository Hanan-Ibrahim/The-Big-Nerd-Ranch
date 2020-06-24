//
//  ItemCell.swift
//  Ownies
//  Created by Han on 17.04.2020.
//  Copyright © 2020 Han. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    // MARK: components of ItemCell
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var serialNumberLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    //MARK: Update labels
    func updateLabels() {
        let bodyFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        nameLabel.font = bodyFont
        valueLabel.font = bodyFont
        
        let caption1Font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        serialNumberLabel.font = caption1Font
    }
}
