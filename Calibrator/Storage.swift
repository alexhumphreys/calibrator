//
//  Storage.swift
//  Calibrator
//
//  Created by Alex Humphreys on 05.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import Foundation




class Storage : NSObject {
    static let sharedStorage: Storage = {
        let s = Storage()
        var pg = PredictionGroup()
        pg.predictions += [
            Prediction(content: "X will win sport", probability: 70, state: .pending),
            Prediction(content: "Y will increase in value", probability: 60, state: .pending),
            Prediction(content: "Z will still be a mess", probability: 80, state: .pending)
        ]
        s.predictionGroup = pg
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
}


extension Storage {
    func saveToDisk() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(predictions, toFile: Prediction.ArchiveURL.path)
//
//        if isSuccessfulSave {
//            os_log("Predictions successfully saved.", log: OSLog.default, type: .debug)
//        } else {
//            os_log("Failed to save predictions...", log: OSLog.default, type: .error)
//        }
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
