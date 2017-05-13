//
//  PredictionLineChart.swift
//  Calibrator
//
//  Created by Alex Humphreys on 13.05.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import Foundation

struct PredictionGraphData {
    let predictionGroup: PredictionGroup

    var linePoints: [Int] {
        return predictionGroup.predictions.map({ (p) -> Int in
            return p.probability
        })
    }

    
}
