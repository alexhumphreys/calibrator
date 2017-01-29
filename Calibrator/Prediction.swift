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
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("predictions")
    
    //MARK: Types
    
    struct PropertyKey {
        static let content = "content"
        static let probability = "probability"
    }
    
    init(content: String, probability: Int) {
        self.content = content
        self.probability = probability
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: PropertyKey.content)
        aCoder.encode(probability, forKey: PropertyKey.probability)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let content = aDecoder.decodeObject(forKey: PropertyKey.content) as? String else {
            os_log("Unable to decode the content for a Prediction object", log: OSLog.default, type: .debug)
            return nil
        }
        
        let probability = aDecoder.decodeInteger(forKey: PropertyKey.probability)
        
        self.init(content: content, probability: probability)
    }
}
