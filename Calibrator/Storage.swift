//
//  Storage.swift
//  Calibrator
//
//  Created by Alex Humphreys on 05.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import Foundation

fileprivate func randomPredictions() -> [Prediction] {
    let predictions: [Prediction] = (0...100).map({ (i) -> Prediction in
        let prob = Int(50 + (arc4random_uniform(11)*5))
        return Prediction.init(content: UUID().uuidString,
                               probability: prob,
                               state: Prediction.State.randomState())
    })
    return predictions
}


class Storage : NSObject {
    static let sharedStorage: Storage = {

        let s = Storage()

        guard let savedPg = readFromDisk() else {
            s.predictionGroup = defaultPredictionGroup()
            return s
        }

        //pg.predictions += randomPredictions()
        s.predictionGroup = savedPg
        return s
    }()

    var predictionGroup: PredictionGroup = PredictionGroup() {
        didSet {
            let oldStorage = Storage()
            oldStorage.predictionGroup = oldValue
            sendNotification(oldStorage: oldStorage)
            saveToDisk()
        }
    }

    private static func defaultPredictionGroup() -> PredictionGroup {
        var pg = PredictionGroup()
        pg.predictions += [
            Prediction(content: "X will win sport", probability: 70, state: .pending),
            Prediction(content: "Y will increase in value", probability: 60, state: .pending),
            Prediction(content: "Z will still be a mess", probability: 80, state: .pending)
        ]

        return pg
    }
}


extension Storage {
    func saveToDisk() {
        let fileName = "Test"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)

        // If the directory was found, we write a file to it and read it back
        if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {

            // Write to the file Test
            let encoder = JSONEncoder()
            let encoded = try? encoder.encode(predictionGroup)

            let outString = String(data: encoded!, encoding: String.Encoding.utf8) ?? "Data could not be printed"


            //let outString = "Write this text to the file"
            do {
                try outString.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }

            // Then reading it back from the file
            do {
                let pg = try JSONDecoder().decode(PredictionGroup.self, from: String(contentsOf: fileURL).data(using: .utf8)!)
                print("decoded!")
                print(pg) // decoded!
                //self.predictionGroup = pg
            } catch {
                print("failed decode")
            }
        }

//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(predictions, toFile: Prediction.ArchiveURL.path)
//
//        if isSuccessfulSave {
//            os_log("Predictions successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            os_log("Failed to save predictions...", log: OSLog.default, type: .error)
//        }
    }

    static func readFromDisk() -> PredictionGroup? {
        let fileName = "Test"
        let dir = try? FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask, appropriateFor: nil, create: true)

        do {
            if let fileURL = dir?.appendingPathComponent(fileName).appendingPathExtension("txt") {
                let savedPredictionGroup = try JSONDecoder().decode(PredictionGroup.self, from: String(contentsOf: fileURL).data(using: .utf8)!)
                return savedPredictionGroup
            } else {
                return nil
            }
        } catch {
            print("Could not read from disk")
            return nil
        }
    }
}


protocol StorageObserver : class {
    func storageDidChange(oldStorage: Storage)
}



extension Storage {
    private static let oldStorageKey = "oldStorage"
    fileprivate func sendNotification(oldStorage: Storage) {
        NotificationCenter.default.post(name: .StorageChangedName, object: self, userInfo: [Storage.oldStorageKey: oldStorage])
    }

    func add(observer: StorageObserver) -> NSObjectProtocol {
        weak var weakObserver = observer
        return NotificationCenter.default.addObserver(forName: .StorageChangedName, object: self, queue: nil) { (note) in
            guard
                let o = weakObserver,
                let oldStorage = note.userInfo?[Storage.oldStorageKey] as? Storage
                else { return }
            o.storageDidChange(oldStorage: oldStorage)
        }
    }

    static func removeObserver(_ token: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(token)
    }
}

fileprivate extension Notification.Name {
    static let StorageChangedName = Notification.Name(rawValue: "storageChanged")
}
