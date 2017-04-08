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
            Prediction(content: "X will increase in value", probability: 60, state: .pending),
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



extension Prediction {
//    init?(fromPlist: Dictionary<String:Any>) {
//
//    }
//    var plist: Dictionary<String:Any> {
//        return [
//            "content": content,
//            "prob": probability,
//
//        ]
//    }
}
extension PredictionGroup {
    //    init?(fromPlist: Dictionary<String:Any>) {
    //
    //    }
//    var plist: Array<Dictionary<String:Any>> {
//        return predictions.map { $0.plist }
//    }
}
extension Storage {
//    func loadFrom(plist: Array<Dictionary<String:Any>>) {
//
//    }
//    var plist: Array<Dictionary<String:Any>> {
//
//    }
//    func foo() {
//        var url = FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        url.appendPathComponent("predictions.plist")
//        let data = Data()
//        try? data.write(to: url)
//
//        guard let data2 = Data(contentsOf: url) else { return }


//        PropertyListSerialization
//        open class func data(fromPropertyList plist: Any, format: PropertyListSerialization.PropertyListFormat, options opt: PropertyListSerialization.WriteOptions) throws -> Data
//        open class func propertyList(from data: Data, options opt: PropertyListSerialization.ReadOptions = [], format: UnsafeMutablePointer<PropertyListSerialization.PropertyListFormat>?) throws -> Any


//    }
}
