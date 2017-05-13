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

    var probabilities: [Int] {
        let probs = predictionGroup.resolved.predictions.map({ (p) -> Int in
            return p.probability
        })
        let uniqProbs = Array(Set(probs))
        return uniqProbs.sorted()
    }

    var linePoints: [Point] {
        return probabilities.map({ (p) -> Point in
            Point.init(x: Float(p), y: accuracy(at: p))
        })
    }

    func accuracy(at: Int) -> Float {
        // TODO: Make nicer

        let pg = PredictionGroup.init(
            predictions: predictionGroup.resolved.predictions.filter({$0.probability == at}))

        let correctCount = Float(pg.select(state: .correct).predictions.count)
        //let incorrectCount = Float(pg.select(state: .incorrect).predictions.count)


        // TODO: zero count?
        return correctCount / Float(pg.predictions.count)
    }
}
