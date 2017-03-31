//
//  Prediction.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit
import os.log

class Prediction: NSObject, NSCoding {
    
    //MARK: Properties
    
    var content: String
    var probability: Int
    var state: State

    let titleLength = 19

    enum State : String {
        case pending = "Pending"
        case overdue = "Overdue"
        case correct = "Correct"
        case incorrect = "Incorrect"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("predictions")
    
    //MARK: Types
    
    struct PropertyKey {
        static let content = "content"
        static let probability = "probability"
        static let state = "state"
    }
    
    init(content: String, probability: Int, state: State = .pending) {
        self.content = content
        self.probability = probability
        self.state = state
    }
    
    func asTitle() -> String {
        if self.content.characters.count < titleLength + 3 {
            return self.content
        } else {
            let index = self.content.characters.index(self.content.characters.startIndex, offsetBy: titleLength)
            return self.content.substring(to: index) + "..."
        }
    }

    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: PropertyKey.content)
        aCoder.encode(probability, forKey: PropertyKey.probability)
        aCoder.encode(state.rawValue, forKey: PropertyKey.state)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let content = aDecoder.decodeObject(forKey: PropertyKey.content) as? String else {
            os_log("Unable to decode the content for a Prediction object", log: OSLog.default, type: .debug)
            return nil
        }
        let stateString = aDecoder.decodeObject(forKey: PropertyKey.state) as? String
        let probability = aDecoder.decodeInteger(forKey: PropertyKey.probability)
        
        if let str = stateString {
            let state = State(rawValue: str)
            self.init(content: content, probability: probability, state: state!)
        } else {
            self.init(content: content, probability: probability, state: .pending)
        }
    }
}
