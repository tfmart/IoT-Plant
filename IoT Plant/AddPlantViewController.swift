//
//  AddPlantViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit

class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    let watsonRecognition = WatsonRecognition()
    var data: Data?
    let plantModel = PlantModel()

    //MARK: IBOutlets
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var addPlantButton: UIButton!
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var invalidNameLabel: UIStackView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var suggestedNameButton: UIButton!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var fadeSuggestedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantButton.layer.cornerRadius = 12.0
        self.plantNameTextField.delegate = self
        suggestedNameButton.isHidden = true
        suggestionLabel.isHidden = true
        suggestedNameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        fadeSuggestedButton.isHidden = true
        
        //Style the UIImageView
        plantImage.layer.cornerRadius = plantImage.frame.height/2
        plantImage.layer.masksToBounds = false
        plantImage.clipsToBounds = true
        watsonRecognition.lookForUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        if(plantNameTextField.validateDatabaseName()) {
            if data == nil {
                data = #imageLiteral(resourceName: "defaultPlant").pngData()
            }
            plantModel.addPlant(name: plantNameTextField.text!, image: data!)
            self.dismiss(animated: true, completion: nil)
        } else {
            //if plant name is invalid
            invalidNameLabel.alpha = 1
            addPlantButton.errorShake(duration: 0.5, values: [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0])
        }
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        let pickPhotoSource = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //Camera Button
        pickPhotoSource.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                
            }
        }))
        //Photo library button
        pickPhotoSource.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        //Cancel button
        pickPhotoSource.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(pickPhotoSource, animated: true, completion: nil)
    }
    
    @IBAction func suggestionButtonPressed(_ sender: UIButton) {
        //makes fadeSuggestionButton appear and animates it
        self.fadeSuggestedButton.alpha = 1
        self.fadeSuggestedButton.isHidden = false
        self.fadeSuggestedButton.fadeOut()
        self.fadeSuggestedButton.titleLabel!.text = "  \(suggestedNameButton.titleLabel!.text!)"
        //Puts suggested name on plantNameTextField
        self.plantNameTextField.text = suggestedNameButton.titleLabel?.text
        self.suggestionLabel.isHidden = true
        self.suggestedNameButton.isHidden = true
        self.invalidNameLabel.alpha = 0
    }
    
    //Handles when the user is pressing and holding the button
    @IBAction func suggestedButtonTouchDown(_ sender: UIButton) {
        sender.setTitle(suggestedNameButton.titleLabel!.text!, for: .normal)
    }
    
    
    @IBAction func changePhotoButtonPressed(_ sender: Any) {
        let pickPhotoSource = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //Camera Button
        pickPhotoSource.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        //Photo library button
        pickPhotoSource.addAction(UIAlertAction(title: "Choose from library", style: .default, handler: { (action) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        //Cancel button
        pickPhotoSource.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(pickPhotoSource, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            plantImage.image = image
            data = image.pngData()!
            self.addPhotoButton.alpha = 0
            self.changePhotoButton.alpha = 1
            //Visual Recognition
            //classifyImage(plantImage.image ?? #imageLiteral(resourceName: "defaultPlant"))
            watsonRecognition.classifyPlant(image: plantImage.image ?? #imageLiteral(resourceName: "defaultPlant"), callback: {(suggestedName) -> Void in
                self.suggestionLabel.isHidden = false
                self.suggestedNameButton.isHidden = false
                self.suggestedNameButton.titleLabel?.text = suggestedName
            })
        } else {
            plantImage.image = #imageLiteral(resourceName: "defaultPlant")
            data = #imageLiteral(resourceName: "defaultPlant").pngData()
        }
    }
    
    //Dismiss keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
