//
//  AddPlantViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 17/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddPlantViewController: UIViewController {
    
    var ref: DatabaseReference?

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        ref?.child("Plants").child(plantNameTextField.text!).childByAutoId().setValue("--.-")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var addPlantButton: UIButton!
    @IBOutlet weak var plantNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlantButton.layer.cornerRadius = 12.0
        
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
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
