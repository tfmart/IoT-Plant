//
//  VisualRecognition.swift
//  IoT Plant
//
//  Created by Tomas Martins on 21/11/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import VisualRecognitionV3
import RestKit

struct WatsonRecognitionConstants {
    static let apiKey = "jK8BkBlwvo4yiqvhIEoYNiRNC7aosPsFxSgrUgalUBJb"
    static let version = "2018-11-12"
    static let modelIds = ["PlantsDataset_1727533516"]
}

class WatsonRecognition {
    let visualRecognition = VisualRecognition(version: WatsonRecognitionConstants.version, apiKey: WatsonRecognitionConstants.apiKey)
    var modelsToUpdate = [String]()
    var suggestedNames = [VisualRecognitionV3.ClassifierResult]()
    
    func lookForUpdates() {
        guard let localModels = try? visualRecognition.listLocalModels() else {
            return
        }
        for modelId in WatsonRecognitionConstants.modelIds {
            // Pull down model if none on device
            // This only checks if the model is downloaded, we need to change this if we want to check for updates when then open the app
            if !localModels.contains(modelId) {
                modelsToUpdate.append(modelId)
            }
        }
        if modelsToUpdate.count > 0 {
            updateLocalModels(ids: modelsToUpdate)
        }
    }
    
    func updateLocalModels(ids modelIds: [String]) {
        let dispatchGroup = DispatchGroup()
        // If the array is empty the dispatch group won't be notified so we might end up with an endless spinner
        dispatchGroup.enter()
        for modelId in modelIds {
            dispatchGroup.enter()
            let failure = { (error: Error) in
                dispatchGroup.leave()
                DispatchQueue.main.async {
                    self.modelUpdateFail(modelId: modelId, error: error)
                }
            }
            
            let success = {
                dispatchGroup.leave()
            }
            
            visualRecognition.updateLocalModel(classifierID: "PlantsDataset_1727533516", failure: failure, success: success)
        }
        dispatchGroup.leave()
    }
    
    func modelUpdateFail(modelId: String, error: Error) {
        let error = error as NSError
        
        // 0 = wrong api key
        // 404 = no model
        // -1009 = no internet
        
        switch error.code {
        case 0:
            print("Please check your Visual Recognition API key in `Credentials.plist` and try again.")
        case 404:
            print("We couldn't find the model with ID: \"\(modelId)\"")
        case 500:
            print("Internal server error. Please try again.")
        case -1009:
            print("Please check your internet connection.")
        default:
            print("Please try again.")
        }
    }
    
    func classifyPlant(image: UIImage, callback: @escaping ((_ suggestedName: String) -> Void)) {
        let watsonRecognition = WatsonRecognition()
        let failure = { (error: Error) in
            DispatchQueue.main.async {
                print(error)
            }
        }
        
        watsonRecognition.visualRecognition.classifyWithLocalModel(image: image, classifierIDs: WatsonRecognitionConstants.modelIds, threshold: 0.0, failure: failure) { classifiedImages in
            
            // Make sure that an image was successfully classified.
            guard let classifiedImage = classifiedImages.images.first else {
                return
            }
            
            DispatchQueue.main.async {
                if(classifiedImage.classifiers[0].classes[0].score! >= 0.85 ) {
                    callback(classifiedImage.classifiers[0].classes[0].className)
                }
            }
        }
    }

}


