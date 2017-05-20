//
//  LineChartViewController.swift
//  Calibrator
//
//  Created by Alex Humphreys on 13.05.17.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit

class LineChartViewController: UIViewController, LineChartDelegate, StorageObserver {
    var label = UILabel()
    var lineChart = LineChart()

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
        lineChart.clearAll()
        addData()
        self.view.setNeedsDisplay()
        for sv in self.view.subviews {
            sv.setNeedsDisplay()
        }
    }

    deinit {
        if let t = storageToken {
            Storage.removeObserver(t)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        storageToken = storage.add(observer: self)
        storageDidChange(oldStorage: storage)

        addData()
    }

    func addData() {
        let pgd = PredictionGraphData.init(predictionGroup: predictionGroup)

        var views: [String: AnyObject] = [:]

        label.text = "..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = NSTextAlignment.center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-80-[label]", options: [], metrics: nil, views: views))

        let data = pgd.lineYPoints
        //let data2: [CGFloat] = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]
        let data2 = pgd.probabilities.map({ (x) -> CGFloat in
            return CGFloat(x)
        })

        if data.count < 2 {
            return
        }

        // simple line with custom x axis labels
        //let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let xLabels = data2.map({ (x) -> String in
            return String(describing: Int(x))
        })

        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = 5
        lineChart.y.grid.count = 5
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        if data.count > 0 { lineChart.addLine(data) }
        lineChart.addLine(data2)

        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        self.view.addSubview(lineChart)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chart]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-[chart(==200)]", options: [], metrics: nil, views: views))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }



    /**
     * Line chart delegate method.
     */
    func didSelectDataPoint(_ x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "x: \(x)     y: \(yValues)"
    }



    /**
     * Redraw chart on device rotation.
     */
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //if let chart = lineChart {
            //chart.setNeedsDisplay()
        //}
    }
}
