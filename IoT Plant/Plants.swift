//
//  File.swift
//  IoT Plant
//
//  Created by Tomas Martins on 16/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Plant {
    var name: String!
    var humidity: String!
    var image: String!
    
    init(name: String, humidity: String, image: String) {
        self.name = name
        self.humidity = humidity
        self.image = image
    }
}

//Data to fill the CollectionView for demonstration purposes
class DemoPlantDAO {
    var data: [Plant] = [Plant(name: "Living Room Vase", humidity: "41.2", image: "livingRoom")]
    
    static func database() -> [Plant] {
        return [Plant(name: "Living Room Vase", humidity: "41.2", image: "livingRoom"), Plant(name: "White Roses", humidity: "78.4", image: "whiteRoses"), Plant(name: "Bedroom Roses", humidity: "62.1", image: "bedroomRoses")]
    }
}
