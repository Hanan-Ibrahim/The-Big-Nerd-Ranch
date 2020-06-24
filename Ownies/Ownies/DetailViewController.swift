//
//  DetailViewController.swift
//  Ownies
//
//  Created by Han on 17.04.2020.
//  Copyright © 2020 Han. All rights reserved.
//
import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
   
    @IBOutlet var nameField: ColorBorderResponderTextField!
    @IBOutlet var serialNumberField: ColorBorderResponderTextField!
    @IBOutlet var valueField: ColorBorderResponderTextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var item: Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    var imageStore: ImageStore!
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    // MARK: - ImagePicker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Get picked image from info dictionary
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        //Store the image in the ImageStore for the item's key
        imageStore.setImage(image: image, forkey: item.itemKey)
        
        //Put that image on the screen in the image view
        imageView.image = image
        
        // Take image picker off the screen -
        // you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - ButtonActions
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        // Allow picture to be edited
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            // Add Camera overlay
            let cameraOverlay = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            imagePicker.cameraOverlayView = cameraOverlay
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 14: silver
    @IBAction func deletePicture(_ sender: UIBarButtonItem) {
        let key = item.itemKey
        imageStore.deleteImageForKey(key: key)
        imageView.image = imageStore.imageForKey(key: key)
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func setDate(_ date: Date) {
        let stringDate = dateFormatter.string(from: date)
        dateLabel.text = stringDate
    }
    
    
    // MARK: - View life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        serialNumberField.text = item.serialNumber
        valueField.text = numberFormatter.string(from: NSNumber(value: item.valueInDollars))
        dateLabel.text = dateFormatter.string(from: item.dateCreated)
        
        let key = item.itemKey
        let imageToDisplay = imageStore.imageForKey(key: key)
        imageView.image = imageToDisplay
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        
        item.name = nameField.text ?? ""
        item.serialNumber = serialNumberField.text
        
        if let valueText = valueField.text, let value = numberFormatter.number(from: valueText) {
            item.valueInDollars = value.intValue
        } else {
            item.valueInDollars = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Segue
    
    // 13: gold
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetDate" {
            let chooseDateViewController = segue.destination as! ChooseDateViewController
            chooseDateViewController.item = item
        }
    }
}
