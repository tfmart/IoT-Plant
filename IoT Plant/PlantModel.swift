//
//  PlantModel.swift
//  IoT Plant
//
//  Created by Tomas Martins on 12/11/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PlantModel {
    //Loads plants saved locally
    func loadLocalData() -> [Plant] {
        if let loadedData = UserDefaults().data(forKey: "plantList") {
            if let loadedPlant = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Plant] {
                return loadedPlant
            }
        }
        //In case there are no plants saved locally, it returns an empty string
        return []
    }
    
    //MARK: Functions for AddPlantViewController
    
    func addPlant(name: String, image: Data) {
        var ref: DatabaseReference?
        ref = Database.database().reference()
        
        //Adiciona um valor para humidade
        ref?.child("Plants").child(name).childByAutoId().setValue("--.-")
        
        //Upload image to Firebase Storage
        let plantImageRef: StorageReference? = Storage.storage().reference()
        plantImageRef?.child("images/\(name)/image.png").putData(image, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Error occurred: \(String(describing: error))")
                return
            }
        }
    }
    
    func deletePlant(index: Int) {
        var plants = loadLocalData()
        //Deletes plant from Firebase
        let deleteRef = Database.database().reference()
        let ref = deleteRef.child("Plants/\(plants[index].name)")
        
        ref.removeValue { error, _ in
            if let error = error {
                print("Error \(error)")
            }
        }
        
        let storage = Storage.storage().reference()
        let storageRef = storage.child("images/\(plants[index].name)/image.png")
        
        //Removes image from storage
        storageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                print("Image successfully deleted")
            }
        }
        
        //Removes plant from Core Data
        plants.remove(at: index)
        let plantsData = NSKeyedArchiver.archivedData(withRootObject: plants)
        UserDefaults.standard.set(plantsData, forKey: "plantList")
    }
}
