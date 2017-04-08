//
//  PredictionGraphViewController.swift
//  Calibrator
//
//  Created by Alex Humphreys on 08.04.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

class PredictionGraphViewController: UIViewController, StorageObserver {

    //Mark: Properties
    @IBOutlet weak var graphView: GraphView!

    override func viewDidLoad() {
        super.viewDidLoad()

        storageToken = storage.add(observer: self)
        storageDidChange(oldStorage: storage)

        self.graphView.predictions = predictions
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate let storage = Storage.sharedStorage
    fileprivate var predictionGroup: PredictionGroup {
        get {
            return storage.predictionGroup
        }
    }
    fileprivate var predictions: [Prediction] {
        get {
            return predictionGroup.predictions
        }
    }

    private var storageToken : NSObjectProtocol?


    func storageDidChange(oldStorage: Storage) {
        let _ = oldStorage.predictionGroup.predictions.diff(storage.predictionGroup.predictions)
        self.graphView.predictions = predictions
        graphView.setNeedsDisplay()
    }

    deinit {
        if let t = storageToken {
            Storage.removeObserver(t)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        print(predictions.count)
    }
}
