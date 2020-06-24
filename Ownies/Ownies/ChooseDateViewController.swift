//
//  ChooseDateViewController.swift
//  Ownies
//
//  Created by Han on 17.04.2020.
//  Copyright © 2020 Han. All rights reserved.
//
import UIKit

class ChooseDateViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!
    var item: Item!

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .date
        datePicker.date = item.dateCreated
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        item.dateCreated = datePicker.date
    }

}
