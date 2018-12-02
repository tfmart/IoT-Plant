//
//  ViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 15/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    var plantList = [Plant]()
    var filteredPlants = [Plant]()
    var plantData = PlantModel()
    let search = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get new plants
        plantList = plantData.loadLocalData()
        self.listCollectionView.reloadData()
        PlantDAO.getPlants(callback: {(plants, fetchStatus) -> Void in
            if fetchStatus {
                self.plantList = plants
                self.listCollectionView.reloadData()
                self.plantData.savePlants(plants: self.plantList)
            }
        })
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
        
        self.listCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        plantList = plantData.loadLocalData()
        self.listCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPlants.count
        }
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
        //Style the cell
        cell.mainScreenStyle()
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.7
        //Style the UIImageView
        cell.plantImage.mainScreenStyle()
        
        return cell
    }
    
    //MARK: Segue for when a plant is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "detail") as! PlantDetailViewController
        viewController.modalTransitionStyle = .coverVertical
        if isFiltering() {
            viewController.plantFromCell = filteredPlants[indexPath.row]
            viewController.plantIndex = indexPath.row
        } else {
            viewController.plantFromCell = plantList[indexPath.row]
            viewController.plantIndex = indexPath.row
        }
        viewController.recievedList = plantList
        self.present(viewController, animated: true, completion: nil)
    }
    
    //MARK: Search Methods
    func searchBarIsEmpty() -> Bool {
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
    
    //MARK: Long Press Function
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }
        
        let point = longPressGR.location(in: self.listCollectionView)
        let indexPath = self.listCollectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            let deletePlantMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            deletePlantMenu.addAction(UIAlertAction(title: "Delete Plant", style: .destructive, handler: { (action) -> Void in
                let confirmActionAlert = UIAlertController(title: "Delete Plant", message: "Are you sure you want to delete \(self.plantList[indexPath.row].name)? This action cannot be undone!", preferredStyle: .alert)
                confirmActionAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                    self.plantData.deletePlant(index: indexPath.row)
                    self.plantList = self.plantData.loadLocalData()
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
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        
    }
}
