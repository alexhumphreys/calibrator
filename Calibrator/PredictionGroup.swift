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

    var resolved: PredictionGroup {
        let correct = self.select(state: .correct).predictions
        let incorrect = self.select(state: .incorrect).predictions

        return PredictionGroup.init(predictions: correct + incorrect)
    }

    func select(state: Prediction.State)-> PredictionGroup {
        return PredictionGroup.init(predictions: predictions.filter({$0.state == state}))
    }
}
