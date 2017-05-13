//
//  PredictionGroup.swift
//  Calibrator
//
//  Created by Alex Humphreys on 08.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import Foundation


struct PredictionGroup {
    var predictions: [Prediction] = []

    var resolvedPredictions: [Prediction] {
        return predictions.filter({$0.state == .correct || $0.state == .incorrect})
    }
}
