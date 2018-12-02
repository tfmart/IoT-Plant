//
//  Extensions.swift
//  IoT Plant
//
//  Created by Tomas Martins on 21/11/18.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import Foundation
import UIKit

public extension UITextField {
    //validates the name of the plant
    func validateDatabaseName() -> Bool {
        if (self.text?.isEmpty)! || (self.text?.contains("."))! || (self.text?.contains("#"))! || (self.text?.contains("$"))! || (self.text?.contains("["))! || (self.text?.contains("]"))! {
            return false
        } else {
            return true
        }
    }
}

public extension UIView {
    //Error animation when plant name input is not valid
    func errorShake(duration: TimeInterval = 0.5, values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        let originalColor = self.backgroundColor
        
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = UIColor.red
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = originalColor
        }, completion: nil)
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.values = values
        self.layer.add(animation, forKey: "shake")
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func mainScreenStyle() {
        self.layer.cornerRadius = 20.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
}

public extension UIImage {
    //Extension to darken image
    func tinted(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        guard let cgImage = cgImage else { return self }
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        // darken image
        let rect = CGRect(origin: .zero, size: size)
        context.draw(cgImage, in: rect)
        UIColor(white: 0, alpha: 0.15).setFill()
        context.fill(rect)
        
        // create uiimage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
}

extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

