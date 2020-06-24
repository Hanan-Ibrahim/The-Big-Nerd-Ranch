//
//  ColorBorderResponderTextField.swift
//  Ownies
//
//  Created by Han on 17.04.2020.
//  Copyright © 2020 Han. All rights reserved.
//
import UIKit

// MARK: custom text fields
class ColorBorderResponderTextField: UITextField {
    
    override func becomeFirstResponder() -> Bool {
        let a = super.becomeFirstResponder()
        self.borderStyle = .none
        return a
    }
    
    override func resignFirstResponder() -> Bool {
        self.borderStyle = .line
        super.resignFirstResponder()
        self.borderStyle = .line
        return true
    }
}
