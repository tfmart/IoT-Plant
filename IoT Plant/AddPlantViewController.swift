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
import VisualRecognitionV3
import RestKit

struct VisualRecognitionConstrains {
    static let apiKey = "jK8BkBlwvo4yiqvhIEoYNiRNC7aosPsFxSgrUgalUBJb"
    static let version = "2018-09-16"
    static let modelIds = ["PlantsDataset_1727533516"]
}

class AddPlantViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let visualRecognition = VisualRecognition(version: VisualRecognitionConstrains.version, apiKey: VisualRecognitionConstrains.apiKey)
    var modelsToUpdate = [String]()
    
    var ref: DatabaseReference?
    var data: Data?
    
    var suggestedNames = [VisualRecognitionV3.ClassifierResult]()

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
        
        guard let localModels = try? visualRecognition.listLocalModels() else {
            return
        }
        for modelId in VisualRecognitionConstrains.modelIds {
            // Pull down model if none on device
            // This only checks if the model is downloaded, we need to change this if we want to check for updates when then open the app
            if !localModels.contains(modelId) {
                modelsToUpdate.append(modelId)
            }
        }
        
        if modelsToUpdate.count > 0 {
            updateLocalModels(ids: modelsToUpdate)
        }
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
            //Visual Recognition
            classifyImage(plantImage.image ?? #imageLiteral(resourceName: "defaultPlant"))
        } else {
            plantImage.image = #imageLiteral(resourceName: "defaultPlant")
            data = UIImagePNGRepresentation(#imageLiteral(resourceName: "defaultPlant"))
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    //Downloads Plant Recognizer Model from Watson
    func updateLocalModels(ids modelIds: [String]) {
        let dispatchGroup = DispatchGroup()
        // If the array is empty the dispatch group won't be notified so we might end up with an endless spinner
        dispatchGroup.enter()
        for modelId in modelIds {
            dispatchGroup.enter()
            let failure = { (error: Error) in
                dispatchGroup.leave()
                DispatchQueue.main.async {
                    self.modelUpdateFail(modelId: modelId, error: error)
                }
            }
            
            let success = {
                dispatchGroup.leave()
            }
            
            visualRecognition.updateLocalModel(classifierID: "PlantsDataset_1727533516", failure: failure, success: success)
        }
        dispatchGroup.leave()
    }
    
    func modelUpdateFail(modelId: String, error: Error) {
        let error = error as NSError
        
        // 0 = probably wrong api key
        // 404 = probably no model
        // -1009 = probably no internet
        
        switch error.code {
        case 0:
            print("Please check your Visual Recognition API key in `Credentials.plist` and try again.")
        case 404:
            print("We couldn't find the model with ID: \"\(modelId)\"")
        case 500:
            print("Internal server error. Please try again.")
        case -1009:
            print("Please check your internet connection.")
        default:
            print("Please try again.")
        }
        
        // TODO: Do some more checks, does the model exist? is it still training? etc.
        // The service's response is pretty generic and just guesses.
    }
    
    func classifyImage(_ image: UIImage, localThreshold: Double = 0.0) {
        
        let failure = { (error: Error) in
            DispatchQueue.main.async {
                print(error)
            }
        }
        
        visualRecognition.classifyWithLocalModel(image: image, classifierIDs: VisualRecognitionConstrains.modelIds, threshold: localThreshold, failure: failure) { classifiedImages in
            
            // Make sure that an image was successfully classified.
            guard let classifiedImage = classifiedImages.images.first else {
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Push the classification results of all the provided models to the ResultsTableView.
                //print(classifiedImage.classifiers[0].classes[0].className)
                //print(classifiedImage.classifiers[0].classes[0].score!)
                if(classifiedImage.classifiers[0].classes[0].score! >= 0.9 ) {
                    print(classifiedImage.classifiers[0].classes[0].score!)
                    self.plantNameTextField.text = classifiedImage.classifiers[0].classes[0].className
                }
            }
        }
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
