//
//  PlantDetailViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

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
    
    var humidityData: [String]?
    var plantFromCell: Plant?
    
    var recievedList = [Plant]()
    
    var imageVar: UIImage!
    
    var plantIndex: Int?
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var data: Data?
    
   //Action Buttons
    @IBAction func updateButtonPressed(_ sender: Any) {
        humidityLabel.alpha = 0
        humidityTitleLabel.alpha = 0
        updateIndicator.alpha = 1
        
        ref = Database.database().reference()
        
        //Get data from Firebase
        databaseHandle = ref?.child("Plants").child("\((plantFromCell?.name)!)").observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String
            
            if let actualPost = post {
                self.humidityLabel.text = actualPost
            }
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
            let valueRead: String = textField.text!
            //Add value read to Firebase
            self.ref?.child("Plants").child((self.plantFromCell?.name)!).childByAutoId().setValue(valueRead)
            print("Valor adicionado: \(valueRead)")
        }))
        //Pressing Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
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
        
        ref = Database.database().reference()
        
        //Get data from Firebase
        databaseHandle = ref?.child("Plants").child("\((plantFromCell?.name)!)").observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String

            if let actualPost = post {
                self.humidityLabel.text = actualPost
            }
      })

        
        nameLabel.text = plantFromCell?.name
        image.image = plantFromCell?.image
        image.image = image.image?.tinted(color: .black)
        
        //style the buttons
        updateButton.layer.cornerRadius = 12.0
        historyButton.layer.cornerRadius = 12.0
        addButton.layer.cornerRadius = 12.0
        
        //change status bar color to white
        UIApplication.shared.statusBarStyle = .lightContent

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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
         let viewController = storyboard?.instantiateViewController(withIdentifier: "list") as! ViewController
        picker.dismiss(animated: true, completion: nil)
        
        if let newImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //Updates image locally
            image.image = newImage
            print("Size of plantList = \(viewController.plantList.count)")
            recievedList[plantIndex!].image = newImage
            viewController.plantList = recievedList
            
            //Updates image on Firebase Storage
            let plantImageRef: StorageReference? = Storage.storage().reference()
            if data == nil {
                data = UIImagePNGRepresentation(newImage)
            }
            
            plantImageRef?.child("images/\((plantFromCell?.name)!)/image.png").putData(data!, metadata: nil) { (metadata, error) in
                guard metadata != nil else {
                    print("Error occurred: \(String(describing: error))")
                    return
                }
            }
        }
    }


}

extension UIImage {
    //Extension to darken image
    func tinted(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        guard let cgImage = cgImage else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        // darken image
        let rect = CGRect(origin: .zero, size: size)
        context.draw(cgImage, in: rect)
        UIColor(white: 0, alpha: 0.15).setFill()
        context.fill(rect)
        
        // create uiimage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
}
