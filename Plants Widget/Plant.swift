//
//  File.swift
//  IoT Plant
//
//  Created by Tomas Martins on 16/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import UIKit

class Plant: NSObject, NSCoding {
    var name: String!
    var humidity: String!
    //var image: String!
    var image: UIImage!
    
    //init(name: String, humidity: String, image: String) {
    init(name: String, humidity: String, image: UIImage) {
        self.name = name
        self.humidity = humidity
        self.image = image
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(humidity, forKey: "humidity")
        aCoder.encode(image, forKey: "image")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.humidity = aDecoder.decodeObject(forKey: "humidity") as? String ?? ""
        self.image = aDecoder.decodeObject(forKey: "image") as? UIImage
        
    }
}
