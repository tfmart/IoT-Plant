//
//  ViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 15/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loadingPlantsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    var plantList = [Plant]()
    var filteredPlants = [Plant]()
    let search = UISearchController(searchResultsController: nil)
    var lastKey: String = ""
    var lastHumidity: String = ""
    var plantsFromDB = [String]()
    var plantListSize = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listCollectionView.reloadData()
        //plantList = DemoPlantDAO.database()
        
        if let loadedData = UserDefaults().data(forKey: "plantList") {
            if let loadedPlant = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Plant] {
                plantList = loadedPlant
                //lastKey = plantList[plantList.count-1].name
                lastKey = plantList[0].name
                lastHumidity = "..."
            }
        } else {
            print("Nothing has been saved")
        }
        
        plantListSize = plantList.count
        
        //Function to get the plants and their latest humidity value on Firebase
        getPlants()
        
        // Setup the Search Controller
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Plants"
        navigationItem.searchController = search
        definesPresentationContext = true
        self.navigationItem.searchController = search
        
        //Long Press Handlers
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.listCollectionView.addGestureRecognizer(longPressGR)
        
        // Do any additional setup after loading the view, typically from a nib.
        self.listCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload data when user comes back from another view
        getPlants()
        //Saves plantList locally in case data is updated
        let plantsData = NSKeyedArchiver.archivedData(withRootObject: self.plantList)
        UserDefaults.standard.set(plantsData, forKey: "plantList")
        
        self.listCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            //If user is searching for a plant, the collectionView return the results
            return filteredPlants.count
        }
        //else, it just return all the plants
        return plantList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as! PlantListCollectionViewCell
        let plant: Plant
        
        if isFiltering() {
            plant = filteredPlants[indexPath.row]
        } else {
            plant = plantList[indexPath.row]
        }

        //Fill in the labels and image on the cell
        cell.plantName.text = plant.name
        cell.plantHumidity.text = plant.humidity
        cell.plantImage.image = plant.image

        //Darken the image
        //cell.plantImage.image = cell.plantImage.image?.tinted(color: .black)

        //Style the cell
        cell.layer.cornerRadius = 20.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true

        cell.plantImage.layer.cornerRadius = 20.0
        cell.plantImage.layer.borderWidth = 1.0
        cell.plantImage.layer.borderColor = UIColor.clear.cgColor
        cell.plantImage.layer.masksToBounds = true

        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.7
        //cell.layer.shadowPath = UIBezierPath(roundedRect: cell.plantImage.bounds, cornerRadius: cell.plantImage.layer.cornerRadius).cgPath
        
        
        return cell
    }
    
    //Segue for when a plant from the list is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as! PlantListCollectionViewCell
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detail") as! PlantDetailViewController
        viewController.modalTransitionStyle = .coverVertical
        if isFiltering() {
            viewController.plantFromCell = filteredPlants[indexPath.row]
            viewController.imageVar = cell.plantImage.image
            viewController.plantIndex = indexPath.row
        } else {
            viewController.plantFromCell = plantList[indexPath.row]
            viewController.imageVar = cell.plantImage.image
            viewController.plantIndex = indexPath.row
        }
        viewController.recievedList = plantList
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    //Get plant data from Firebase DB
    func getPlants() {
        let plantRef: DatabaseReference? = Database.database().reference()
        let humidityRef: DatabaseReference? = Database.database().reference()
        var checkPlant = 0
        
        //Image vars
        let store = Storage.storage()
        let storeRef = store.reference()
        
        plantRef?.child("Plants").observeSingleEvent(of: .value, with: {(snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                
                if(self.plantsFromDB.contains(rest.key) == false) {
                    //Fills plantFromDB, that will be later used to compare data from the server to locally stored data
                    self.plantsFromDB.append(rest.key);
                }
                
                let results = self.plantList.filter { $0.name == rest.key }
                if(results.isEmpty) {
                    //Look for plant image
                    let plantRef = storeRef.child("images/\(rest.key)/image.png")
                    plantRef.getData(maxSize: 1 * 2048 * 2048) { imageData, error in
                        var returnedImage: UIImage
                        if let error = error {
                            print("Error \(error)")
                            returnedImage = #imageLiteral(resourceName: "defaultPlant")
                        } else {
                            print("Getting image for \(rest.key)")
                            returnedImage = UIImage(data: imageData!)!
                        }
                        
                        //Looks for latest humidity data found on a plant
                        humidityRef?.child("Plants").child(rest.key).observe(.childAdded, with: {(data) in
                            //Checks if the plant is already on plantList array
                            for plants in 0..<self.plantList.count {
                                if self.plantList[plants].name == rest.key {
                                    //Updates humidity value to the most recent one on the database
                                    self.plantList[plants].humidity = data.value as? String
                                    checkPlant = 1
                                }
                            }
                            //Registers a new plant if it hasn't been registered on the array already
                            if checkPlant == 0 {
                                self.plantList.append(Plant(name: rest.key, humidity: data.value as! String, image: returnedImage))
                            }
                            //Save plant list locally
                            let plantsData = NSKeyedArchiver.archivedData(withRootObject: self.plantList)
                            UserDefaults.standard.set(plantsData, forKey: "plantList")

                            checkPlant = 0
                            self.loadingPlantsIndicator.alpha = 0
                            self.listCollectionView.reloadData()
                        })
                    }
                } else {
                    //Update humidity values of existing plants
                    
                    //Looks for latest humidity data found on a plant
                    humidityRef?.child("Plants").child(rest.key).observe(.childAdded, with: {(data) in
                        if(self.lastKey != rest.key) {
                            for plants in 0..<self.plantListSize {
                                if(plants < self.plantListSize) {
                                    if self.plantList[plants].name == self.lastKey && self.plantList[plants].humidity != self.lastHumidity{
                                        //Updates humidity value to the most recent one on the database
                                        self.plantList[plants].humidity = self.lastHumidity
                                        //Save plant list locally
                                        let plantsData = NSKeyedArchiver.archivedData(withRootObject: self.plantList)
                                        UserDefaults.standard.set(plantsData, forKey: "plantList")
                                    }
                                    //Checks if plantList still stores a plant deleted from server. If it does, the plant is removed locally
                                    if self.plantsFromDB.contains(self.plantList[plants].name!) == false {
                                        print("Removing \(self.plantList[plants].name!)")
                                        self.plantList.remove(at: plants)
                                        self.plantListSize = self.plantList.count
                                    
                                    }
                                }
                            }
                            self.lastKey = rest.key
                        } else {
                            self.lastHumidity = data.value as! String
                        }

                        self.loadingPlantsIndicator.alpha = 0
                        self.listCollectionView.reloadData()
                    })
                }
            }
        })
    }
    
    //MARK: Search Methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return search.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlants = plantList.filter({( plant : Plant) -> Bool in
            return plant.name.lowercased().contains(searchText.lowercased())
        })
        
        self.listCollectionView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return search.isActive && !searchBarIsEmpty()
    }
    
    //Long Press Function
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }
        
        let point = longPressGR.location(in: self.listCollectionView)
        let indexPath = self.listCollectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            //var cell = self.listCollectionView.cellForItem(at: indexPath)
            let deletePlantMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            deletePlantMenu.addAction(UIAlertAction(title: "Delete Plant", style: .destructive, handler: { (action) -> Void in
                let confirmActionAlert = UIAlertController(title: "Delete Plant", message: "Are you sure you want to delete \(self.plantList[indexPath.row].name!)? This action cannot be undone!", preferredStyle: .alert)
                confirmActionAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                    //delete plant
                    let deleteRef = Database.database().reference()
                    let ref = deleteRef.child("Plants/\(self.plantList[indexPath.row].name!)")
                    
                    ref.removeValue { error, _ in
                        if let error = error {
                            print("Error \(error)")
                        }
                    }
                    
                    let storage = Storage.storage().reference()
                    let storageRef = storage.child("images/\(self.plantList[indexPath.row].name!)/image.png")
                    
                    //Removes image from storage
                    storageRef.delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            print("Image successfully deleted")
                        }
                    }

                    
                    self.plantList.remove(at: indexPath.row)
                    let plantsData = NSKeyedArchiver.archivedData(withRootObject: self.plantList)
                    UserDefaults.standard.set(plantsData, forKey: "plantList")
                    self.listCollectionView.reloadData()

                    
                }))
                confirmActionAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(confirmActionAlert, animated: true, completion: nil)
            }))
            deletePlantMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(deletePlantMenu, animated: true, completion: nil)
            
        } else {
            print("Could not find index path")
        }
    }

}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

