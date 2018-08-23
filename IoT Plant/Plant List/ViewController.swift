//
//  ViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 15/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Container to show empty list message
    @IBOutlet weak var emptyListScreen: UIView!
    
    @IBOutlet weak var loadingPlantsIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    //button to add a new plant
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
    
    var plantList = [Plant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listCollectionView.reloadData()
        //plantList = DemoPlantDAO.database()
        if plantList.count == 0 {
            emptyListScreen.alpha = 1
        } else {
            emptyListScreen.alpha = 0
        }
        
        //Function to get the plants and their latest humidity value on Firebase
        getPlants()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.listCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload data when user comes back from another view
        getPlants()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as! PlantListCollectionViewCell
        
        //Fill in the labels and image on the cell
        cell.plantName.text = plantList[indexPath.row].name
        cell.plantHumidity.text = plantList[indexPath.row].humidity
        cell.plantImage.image = UIImage(named: plantList[indexPath.row].image)
        //cell.plantImage.image = cell.plantImage.image?.tinted(color: .black)
        
        //Style the cell
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = false
        
        cell.plantImage.layer.cornerRadius = 20.0
        cell.plantImage.layer.borderWidth = 1.0
        cell.plantImage.layer.borderColor = UIColor.clear.cgColor
        cell.plantImage.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 10.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    //Segue when a cell from the list is selected
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "detail" {
//            if let selectedPlant = segue.destination as? PlantDetailViewController {
//                if let cell = sender as? PlantDetailViewController {
//                    //if let indexPath = 
//                }
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detail") as! PlantDetailViewController
        viewController.modalTransitionStyle = .coverVertical
        viewController.plantFromCell = plantList[indexPath.row]
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    //Get plant data from Firebase DB
    func getPlants() {
        let plantRef: DatabaseReference? = Database.database().reference()
        let humidityRef: DatabaseReference? = Database.database().reference()
        var checkPlant = 0
        
        //Looks for registered plants
        plantRef?.child("Plants").observeSingleEvent(of: .value, with: {(snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                //Looks for latest humidity data found on a plant
                humidityRef?.child("Plants").child(rest.key).observe(.childAdded, with: {(data) in
                    //Checks if the plant is already on plantList array
                    for plants in 0..<self.plantList.count {
                        if self.plantList[plants].name == rest.key {
                            //Updates humidity value to the most recent one on the database
                            self.plantList[plants].humidity = data.value as! String
                            checkPlant = 1
                        }
                    }
                    //Registers a new plant if it hasn't been registered on the array already
                    if checkPlant == 0 {
                        self.plantList.append(Plant(name: rest.key, humidity: data.value as! String, image: "bedroomRoses"))
                    }
                    checkPlant = 0
                    self.listCollectionView.reloadData()
                })
                
            }
            
        })

    }

}

