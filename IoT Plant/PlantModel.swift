//
//  PlantModel.swift
//  IoT Plant
//
//  Created by Tomas Martins on 12/11/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation

class PlantModel {
    
    //Loads plants saved on disk
    func loadLocalData() -> [Plant] {
        if let loadedData = UserDefaults().data(forKey: "plantList") {
            if let loadedPlant = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? [Plant] {
                return loadedPlant
            }
        }
        //In case there are no plants saved locally, it returns an empty string
        return []
    }
}
