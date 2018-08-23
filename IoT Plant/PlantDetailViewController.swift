//
//  PlantDetailViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlantDetailViewController: UIViewController {

    //Outlets
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var humidityTitleLabel: UILabel!
    @IBOutlet weak var lastUpdatedTitleLabel: UILabel!
    @IBOutlet weak var updateIndicator: UIActivityIndicatorView!
    
    var humidityData: [String]?
    var plantFromCell: Plant?
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
   //Action Buttons
    @IBAction func updateButtonPressed(_ sender: Any) {
        lastUpdatedLabel.alpha = 0
        lastUpdatedTitleLabel.alpha = 0
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
        
        lastUpdatedLabel.alpha = 1
        lastUpdatedTitleLabel.alpha = 1
        humidityLabel.alpha = 1
        humidityTitleLabel.alpha = 1
        updateIndicator.alpha = 0
        
    }
    @IBAction func historyButtonPressed(_ sender: Any) {
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
        image.image = UIImage(named: (plantFromCell?.image)!)
        image.image = image.image?.tinted(color: .blue)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
