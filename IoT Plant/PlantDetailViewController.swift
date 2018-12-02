//
//  PlantDetailViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var humidityTitleLabel: UILabel!
    @IBOutlet weak var updateIndicator: UIActivityIndicatorView!
    
    //Plant selected on ViewController
    var plantFromCell: Plant?
    //Plant lis
    var recievedList = [Plant]()
    let plantData = PlantModel()
    var plantIndex: Int?
    
   //Action Buttons
    @IBAction func updateButtonPressed(_ sender: Any) {
        humidityLabel.alpha = 0
        humidityTitleLabel.alpha = 0
        updateIndicator.alpha = 1
        
        PlantDAO.getLatestHumidity(plantName: (plantFromCell?.name)!, callback: {(humidityValue) -> Void in
            self.humidityLabel.text = humidityValue
        })
        
        humidityLabel.alpha = 1
        humidityTitleLabel.alpha = 1
        updateIndicator.alpha = 0
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        //Alert to enable user to input a value
        let alert = UIAlertController(title: "Manual Input", message: "Type a humidity value to manually input", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type here"
        }
        //Pressing Add
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if let valueRead: String = textField.text {
                self.plantData.addHumidity(name: (self.plantFromCell?.name)!, humidity: valueRead, plants: self.recievedList)
            }
        }))
        //Pressing Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Button to change image
    @IBAction func editPhotoButtonPressed(_ sender: Any) {
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
        
        //viewController.plantList[plantIndex!].name = //image loaded from camera or library
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateIndicator.alpha = 0
        
        PlantDAO.getLatestHumidity(plantName: (plantFromCell?.name)!, callback: {(humidityValue) -> Void in
            self.humidityLabel.text = humidityValue
        })

        
        nameLabel.text = plantFromCell?.name
        image.image = plantFromCell?.image
        image.image = image.image?.tinted(color: .black)
        
        //style the buttons
        updateButton.layer.cornerRadius = 12.0
        historyButton.layer.cornerRadius = 12.0
        addButton.layer.cornerRadius = 12.0

        // Do any additional setup after loading the view.
    }
    
    //function to set status bar style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "history" {
            plantName = (plantFromCell?.name)!
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        
        if let newImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            //Updates image locally
            if let imageData = newImage.pngData() {
                plantData.updateImage(imageData: imageData, plantName: (plantFromCell?.name)!)
            } else {
                //Alert: Could not get image data
            }
            image.image = newImage
            recievedList[plantIndex!].image = newImage
            plantData.savePlants(plants: recievedList)
        }
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
