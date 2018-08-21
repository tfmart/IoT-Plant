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
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
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
        
        //Set Firebase Reference
        ref = Database.database().reference()

        ref?.child("Plants").observeSingleEvent(of: .value, with: {(snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                self.plantList.append(Plant(name: rest.key, humidity: "41.2", image: "bedroomRoses"))
                self.listCollectionView.reloadData()
            }
            self.loadingPlantsIndicator.alpha = 0.0

        })
        
        //Retrieve the posts and listens for changes
//        databaseHandle = (ref?.child("Plants").observe(.childAdded, with: { (snapshot) in
//            //convert the value of the data to a string
//            let post = snapshot.value as? String
//
//            if let actualPost = post {
//                self.plantList.append(Plant(name: actualPost, humidity: "41.2", image: "bedroomRoses"))
//                print("Hello \(actualPost)")
//                self.listCollectionView.reloadData()
//            }
//        }))!
        
        // Do any additional setup after loading the view, typically from a nib.
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
        cell.plantImage.image = cell.plantImage.image?.tinted(color: .black)
        
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
    


}

