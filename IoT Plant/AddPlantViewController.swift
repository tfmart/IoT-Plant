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
        ref?.child("Plants").child(plantNameTextField.text!).childByAutoId().setValue("--.-")
        
        //Upload image to Firebase Storage
        let plantImageRef: StorageReference? = Storage.storage().reference()
        if data == nil {
            data = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPlant"))
        }
        
        plantImageRef?.child("images/\(plantNameTextField.text!)/image.png").putData(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Error occurred: \(String(describing: error))")
                return
            }
            //print("download url for profile is \(metadata.downloadURL)")
        }
        
        //Append created plant to list of plants at ViewController
        if let presenter = (presentingViewController as? UINavigationController)?.viewControllers.last as? ViewController {
            presenter.plantList.append(Plant(name: plantNameTextField.text!, humidity: "--.-", image: plantImage.image!))
        }
        
        
        self.dismiss(animated: true, completion: nil)
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
