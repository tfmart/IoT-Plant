//
//  PlantModel.swift
//  IoT Plant
//
//  Created by Tomas Martins on 12/11/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

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
    
    func savePlants(plants: [Plant]) {
        let plantsData = NSKeyedArchiver.archivedData(withRootObject: plants)
        UserDefaults.standard.set(plantsData, forKey: "plantList")
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
        
        var localList = loadLocalData()
        localList.append(Plant(name: name, humidity: "--.-", image: UIImage(data: image) ?? #imageLiteral(resourceName: "defaultPlant")))
        savePlants(plants: localList)
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
        
        //Removes plant from local data
        plants.remove(at: index)
        let plantsData = NSKeyedArchiver.archivedData(withRootObject: plants)
        UserDefaults.standard.set(plantsData, forKey: "plantList")
    }
    
    func addHumidity(name: String, humidity: String, plants: [Plant]) {
        let ref = Database.database().reference()
        ref.child("Plants").child(name).childByAutoId().setValue(humidity)
        print("Valor adicionado: \(humidity)")
        if let searchPlant = plants.first(where: {$0.name == name}) {
            searchPlant.humidity = humidity
            savePlants(plants: plants)
        }
    }
    
    func updateImage(imageData: Data, plantName: String) {
        let plantImageRef: StorageReference? = Storage.storage().reference()
        //Removes current image from Firebase
        plantImageRef?.child("images/\(plantName)/image.png").delete { error in
            if let error = error {
                print(error)
            } else {
                print("File deleted successfully")
            }
        }
        //Then uploads the new image to the server
        plantImageRef?.child("images/\(plantName)/image.png").putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Error occurred: \(String(describing: error))")
                return
            }
        }
    }
}

class PlantDAO {
    static func getHumidityHisotry(plantName: String, callback: @escaping ((_ history: [String]) -> Void)) {
        let historyReference = Database.database().reference()
        var historyValues = [String]()
        historyReference.child("Plants").child(plantName).observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String
            if let actualPost = post {
                if (actualPost != "--.-") {
                    historyValues.append(actualPost)
                }
                callback(historyValues)
            }
        })
    }
    
    static func getLatestHumidity(plantName: String, callback: @escaping ((_ humidity: String) -> Void)) {
        var counter: Int = 0
        let ref = Database.database().reference()
        ref.child("Plants").child("\(plantName)").observe(.value, with: { (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                let result = rest.value as? String
                if let actualResult = result {
                    if counter == snapshot.childrenCount-1 {
                        callback(actualResult)
                    }
                    counter = counter + 1
                }
            }
        })
    }
    
    static func getPlants(callback: @escaping ((_ newPlants: [Plant], _ done: Bool) -> Void)) {
        let plantRef: DatabaseReference? = Database.database().reference()
        let humidityRef: DatabaseReference? = Database.database().reference()
        let storeRef = Storage.storage().reference()
        var plants = [Plant]()
        var fetchStatus = false
        var plantsFromDB = [String]()
        plantRef?.child("Plants").observeSingleEvent(of: .value, with: {(snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                if plantsFromDB.contains(rest.key) == false {
                    plantsFromDB.append(rest.key)
                }
            }
            for (index, name) in plantsFromDB.enumerated() {
                humidityRef?.child("Plants").child(name).observe(.childAdded, with: {(data) in
                    let imageRef = storeRef.child("images/\(name)/image.png")
                    imageRef.getData(maxSize: 1 * 2048 * 2048) { imageData, error in
                        var plantImage: UIImage
                        //In case image download fails
                        if let error = error {
                            print("Error \(error)")
                            plantImage = #imageLiteral(resourceName: "defaultPlant")
                        } else {
                            plantImage = UIImage(data: imageData!)!
                        }
                        
                        if plants.contains(where: { $0.name == name }) {
                            if let searchPlant = plants.first(where: {$0.name == name}) {
                                self.getLatestHumidity(plantName: name, callback: {(humidityValue) -> Void in
                                    searchPlant.humidity = humidityValue
                                })
                            }
                        } else {
                            self.getLatestHumidity(plantName: name, callback: {(humidityValue) -> Void in
                                if plants.contains(where: { $0.name == name }) == false {
                                    plants.append(Plant(name: name, humidity: humidityValue, image: plantImage))
                                }
                            })
                        }
                        if index == plantsFromDB.endIndex-1 {
                            fetchStatus = true
                        }
                        callback(plants, fetchStatus)
                        fetchStatus = false
                    }
                })
            }
        })
    }
}
