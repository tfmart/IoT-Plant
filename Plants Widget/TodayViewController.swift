//
//  TodayViewController.swift
//  Plants Widget
//
//  Created by Tomas Martins on 24/09/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var plantList = [Plant]()
    @IBOutlet weak var todayCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        if let loadedData = UserDefaults().data(forKey: "plantList") {
            if let loadedPlant = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Plant] {
                plantList = loadedPlant
            }
        } else {
            print("Nothing has been saved")
            plantList = [Plant(name: "Bedroom Roses", humidity: "70.9", image: #imageLiteral(resourceName: "defaultPlant.png")), Plant(name: "Cactus", humidity: "40.1", image: #imageLiteral(resourceName: "defaultPlant.png")), Plant(name: "Moon Orchid", humidity: "25.2", image: #imageLiteral(resourceName: "defaultPlant.png"))]
        }
        self.todayCollectionView.reloadData()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    //MARK: CollectionView Protocols
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "todayCell", for: indexPath) as! TodayCollectionViewCell
        cell.humidityLabel.text = plantList[indexPath.row].humidity
        cell.nameLabel.text = plantList[indexPath.row].name
        cell.plantImage.image = plantList[indexPath.row].image
        cell.plantImage.layer.cornerRadius = (65/2)
        return cell
    }
    
}
