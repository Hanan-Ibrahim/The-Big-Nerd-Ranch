//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by Hanoudi on 3/11/20.
//  Copyright © 2020 Hans. All rights reserved.
//

import UIKit
import MapKit

class ConversionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var celsuisLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    var fahrenheitValue: Measurement<UnitTemperature>?{
        didSet{
            updateCelsiusLabel()
        }
    }
    
    var celsuisValue: Measurement<UnitTemperature>?{
        if let fahrenheitValue = fahrenheitValue {
            return fahrenheitValue.converted(to: .celsius)
        }else {
            return nil
        }
    }
    
    func updateCelsiusLabel(){
        if let celsuisValue = celsuisValue{
            celsuisLabel.text = numberFormatter.string(from: NSNumber(value: celsuisValue.value))
        } else{
            celsuisLabel.text = "???"
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer)
    {
        textField.resignFirstResponder()
    }
    
    @IBAction func fahrenheitTextFieldChanged(_ textField: UITextField)
    {
        //doublt init doesnt know how to use a string that has smth other than a period
      // numberFormatter is aware of the Locale
       /* if let text = textField.text, let value = Double(text){
            fahrenheitValue = Measurement(value: value, unit: .fahrenheit)
        */
        
        if let text = textField.text, let number = numberFormatter.number(from: text){
            fahrenheitValue = Measurement(value: number.doubleValue, unit: .fahrenheit)
        }else{
            fahrenheitValue = nil
        }
        
    }
    
    let numberFormatter: NumberFormatter = {
       let nf = NumberFormatter()
       nf.numberStyle = .decimal
       nf.minimumFractionDigits = 0
       nf.maximumFractionDigits = 1
        return nf
      }()
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)->Bool{
    //  let exisitingTextHasDecimalSeparator = textField.text?.range(of: ".")
    //   let replacementTextHasDecimalSeparator = string.range(of: ".")
    
        let currentLocale = Locale.current
        let decimalSeperator = currentLocale.decimalSeparator ?? "."
        
        let exisitingTextHasDecimalSeparator = textField.text?.range(of: decimalSeperator)
        let replacementTextHasDecimalSeparator = string.range(of: decimalSeperator)
        
        let allowedCharacters = CharacterSet(charactersIn: "-+123456789.")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        
        if !replacementStringCharacterSet.isSubset(of: allowedCharacters){
            return false
        }

        if exisitingTextHasDecimalSeparator != nil, replacementTextHasDecimalSeparator != nil{
            return false
        } else{
            return true }
    }
    
    func getRandomColor() -> UIColor{
        //generate a number between 0 and 1
        let red: CGFloat = CGFloat(drand48())
        let green: CGFloat = CGFloat(drand48())
        let blue: CGFloat = CGFloat(drand48())
        
        return UIColor(red: red, green: green, blue: blue, alpha: 5.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = getRandomColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ConversionViewController loaded its view.")
        updateCelsiusLabel()
    }

}

/*
 override func viewDidAppear(_ animated: Bool) {
 let date = Date()
 let hour = Calendar.current.component(.hour, from: date)
 
 if hour > 17 || hour < 6{
 self.view.backgroundColor = UIColor.darkGray
 }
 }
 */
