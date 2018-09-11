//
//  AddPlantViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var ref: DatabaseReference?
    var data: Data?

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var addPlantButton: UIButton!
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var invalidNameLabel: UIStackView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantButton.layer.cornerRadius = 12.0
        ref = Database.database().reference()
        self.plantNameTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        if(plantNameTextField.validateTextFirebase()) {
            ref?.child("Plants").child(plantNameTextField.text!).childByAutoId().setValue("--.-")
            
            //Upload image to Firebase Storage
            let plantImageRef: StorageReference? = Storage.storage().reference()
            if data == nil {
                data = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPlant"))
            }
            
            plantImageRef?.child("images/\(plantNameTextField.text!)/image.png").putData(data!, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    print("Error occurred: \(String(describing: error))")
                    return
                }
                //print("download url for profile is \(metadata.downloadURL)")
            }
            
            //Append created plant to list of plants at ViewController
            if let presenter = (presentingViewController as? UINavigationController)?.viewControllers.last as? ViewController {
                if(plantImage.image == nil) {
                    presenter.plantList.append(Plant(name: plantNameTextField.text!, humidity: "--.-", image: #imageLiteral(resourceName: "defaultPlant")))
                } else {
                    presenter.plantList.append(Plant(name: plantNameTextField.text!, humidity: "--.-", image: plantImage.image!))
                }
            }
            
            
            self.dismiss(animated: true, completion: nil)
        } else {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            plantImage.image = image
            data = UIImagePNGRepresentation(image)!
            self.addPhotoButton.alpha = 0
            self.changePhotoButton.alpha = 1
        } else {
            plantImage.image = #imageLiteral(resourceName: "defaultPlant")
            data = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPlant"))
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    

}

extension UIView {
    // Using CAMediaTimingFunction
    func errorShake(duration: TimeInterval = 0.5, values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        let originalColor = self.backgroundColor
        
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.red
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = originalColor
        }, completion: nil)
        
        // Swift 4.1 and below
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        
        animation.duration = duration // You can set fix duration
        animation.values = values  // You can set fix values here also
        self.layer.add(animation, forKey: "shake")
    }
}

extension UITextField {
    func validateTextFirebase() -> Bool {
        if (self.text?.isEmpty)! || (self.text?.contains("."))! || (self.text?.contains("#"))! || (self.text?.contains("$"))! || (self.text?.contains("["))! || (self.text?.contains("]"))! {
            return false
        } else {
            return true
        }
    }
}
