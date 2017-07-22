//
//  Prediction.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit
import os.log

struct Prediction {
    enum State : String {
        case pending
        case overdue
        case correct
        case incorrect

        static func randomState() -> State {
            let states: [State] = [.pending, .overdue, .correct, .incorrect]
            // pick and return a new value
            let rand = Int(arc4random_uniform(UInt32(states.count)))
            return states[rand]
        }
    }

    var content: String = ""
    var probability: Int = 0
    var state: State = .pending
    let identifier = Prediction.nextIdentifier()
}

extension Prediction.State: Decodable {
    init(rawValue: String) {
        // TODO call super?
        switch rawValue {
        case "pending": self = .pending
        case "overdue": self = .overdue
        case "correct": self = .correct
        case "incorrect": self = .incorrect
        default: self = .pending
        }
    }

    init(from decoder: Decoder) throws {
        enum MyStructKeys: String, CodingKey { // declaring our keys
            case state = "state"
        }

        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        let state: String = try container.decode(String.self, forKey: .state) // extracting the state
        //let twitter: URL = try container.decode(URL.self, forKey: .twitter) // extracting the data

        print(state)
        self.init(rawValue: state)
    }
}

extension Prediction: Decodable, Encodable {
    enum MyStructKeys: String, CodingKey { // declaring our keys
        case content = "content"
        case probability = "probability"
        case state = "state"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MyStructKeys.self)

        try container.encode(content, forKey: .content)
        try container.encode(probability, forKey: .probability)
        try container.encode(state.rawValue, forKey: .state)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MyStructKeys.self) // defining our (keyed) container
        let content: String = try container.decode(String.self, forKey: .content) // extracting the data
        let probability: Int = try container.decode(Int.self, forKey: .probability) // extracting the data
        let state: String = try container.decode(String.self, forKey: .state) // extracting the state
        let state_obj = State.init(rawValue: state)
        //let twitter: URL = try container.decode(URL.self, forKey: .twitter) // extracting the data

        self.init(content: content, probability: probability, state: state_obj) //, twitter: twitter) // initializing our struct
    }
}


extension Prediction : Equatable {
    static func ==(lhs: Prediction, rhs: Prediction) -> Bool {
        return
            lhs.content == rhs.content &&
                lhs.probability == rhs.probability &&
                lhs.state == rhs.state &&
                lhs.identifier == rhs.identifier
    }
}



extension Prediction {
    static let titleLength = 19

    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("predictions")
    
    //MARK: Types
    
    struct PropertyKey {
        static let content = "content"
        static let probability = "probability"
        static let state = "state"
    }
    
    func asTitle() -> String {
        if self.content.characters.count < Prediction.titleLength + 3 {
            return self.content
        } else {
            let index = self.content.characters.index(self.content.characters.startIndex, offsetBy: Prediction.titleLength)
            return self.content.substring(to: index) + "..."
        }
    }

    private static var identifier: Int = 0
    fileprivate static func nextIdentifier() -> Int {
        identifier += 1
        return identifier
    }
}
