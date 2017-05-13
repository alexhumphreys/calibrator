//
//  CalibratorTests.swift
//  CalibratorTests
//
//  Created by Alex Humphreys on 28/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import XCTest
@testable import Calibrator

class CalibratorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func randomPredictions() -> [Prediction] {
        let predictions: [Prediction] = (0...100).map({ (i) -> Prediction in
            let prob = Int(50 + (arc4random_uniform(11)*5))
            return Prediction.init(content: UUID().uuidString,
                            probability: prob,
                            state: Prediction.State.randomState())
        })
        return predictions
    }
    
    func testExample() {
        let predictionGroup = PredictionGroup.init(predictions: randomPredictions())

        for p in predictionGroup.resolved.predictions {
            print(p.probability)
            print(p.state)
        }

        let pgd = PredictionGraphData.init(predictionGroup: predictionGroup)

        print(pgd.accuracy(at: 50))
        print(pgd.probabilities)
        print(pgd.linePoints)
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
