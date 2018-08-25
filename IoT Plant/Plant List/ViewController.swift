//
//  ViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 15/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    //Container to show empty list message
    @IBOutlet weak var emptyListScreen: UIView!
    
    @IBOutlet weak var loadingPlantsIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    //button to add a new plant
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
    
    var plantList = [Plant]()
    var filteredPlants = [Plant]()
    let search = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listCollectionView.reloadData()
        //plantList = DemoPlantDAO.database()
        
        //Function to get the plants and their latest humidity value on Firebase
        getPlants()
        
        // Setup the Search Controller
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Plants"
        navigationItem.searchController = search
        definesPresentationContext = true
        self.navigationItem.searchController = search
        
        // Do any additional setup after loading the view, typically from a nib.
        self.listCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload data when user comes back from another view
        getPlants()
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
        cell.plantImage.image = UIImage(named: plant.image)
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
    
    //Segue for when a plant from the list is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detail") as! PlantDetailViewController
        viewController.modalTransitionStyle = .coverVertical
        if isFiltering() {
            viewController.plantFromCell = filteredPlants[indexPath.row]
        } else {
            viewController.plantFromCell = plantList[indexPath.row]
        }
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

}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

