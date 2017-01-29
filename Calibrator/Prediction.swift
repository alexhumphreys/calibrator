//
//  Prediction.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

class Prediction {
    
    //MARK: Properties
    
    var description: String
    var probability: Int
    
    init(description: String, probability: Int) {
        self.description = description
        self.probability = probability
    }
}
