//
//  Prediction.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

class Prediction: NSObject {
    
    //MARK: Properties
    
    var content: String
    var probability: Int
    
    //MARK: Types
    
    struct PropertyKey {
        static let content = "content"
        static let probability = "probability"
    }
    
    init(content: String, probability: Int) {
        self.content = content
        self.probability = probability
    }
}
