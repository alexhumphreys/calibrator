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
        return predictionGroup.resolved.predictions.map({ (p) -> Int in
            return p.probability
        })
    }

    func accuracy(at: Int) -> Float {
        // TODO: Make nicer

        let pg = PredictionGroup.init(
            predictions: predictionGroup.resolved.predictions.filter({$0.probability == at}))

        let correctCount = Float(pg.select(state: .correct).predictions.count)
        let incorrectCount = Float(pg.select(state: .incorrect).predictions.count)

        return correctCount / Float(pg.predictions.count)
    }
}
