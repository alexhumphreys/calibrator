//
//  PredictionTableViewController.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit
import os.log

class PredictionTableViewController: UITableViewController, SegueHandlerType, StorageObserver {

    enum SegueIdentifier: String {
        case addPredication
        case showDetail
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("vwa")
    }

    //MARK: Properties
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

    override func viewDidLoad() {
        super.viewDidLoad()

        storageToken = storage.add(observer: self)
        storageDidChange(oldStorage: storage)

        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func storageDidChange(oldStorage: Storage) {
        let d = oldStorage.predictionGroup.predictions.diff(storage.predictionGroup.predictions)
        tableView.update(with: d)
    }

    deinit {
        if let t = storageToken {
            Storage.removeObserver(t)
        }
    }
}

fileprivate extension UITableView {
    func update(with diffs: Diff<Prediction>) {
        guard !diffs.results.isEmpty else { return }
        beginUpdates()
        insertRows(at: diffs.insertions.map { IndexPath(row: $0.idx, section: 0) }, with: .automatic)
        deleteRows(at: diffs.deletions.map { IndexPath(row: $0.idx, section: 0) }, with: .automatic)
        endUpdates()
    }
}


// MARK: - Navigation
extension PredictionTableViewController {

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segueIdentifierForSegue(segue) {
        case .addPredication:
            guard
                let destinationVC = segue.destination as? PredictionViewController
                else {
                    fatalError("The selected cell is not being displayed by the table")
            }
            destinationVC.storage = storage
            destinationVC.usage = .add(Prediction())
            os_log("Adding a new prediction.", log: OSLog.default, type: .debug)
        case .showDetail:
            guard
                let destinationVC = segue.destination as? PredictionViewController,
                let cell = sender as? PredictionTableViewCell,
                let indexPath = tableView.indexPath(for: cell)
                else {
                    fatalError("The selected cell is not being displayed by the table")
            }
            destinationVC.storage = storage
            destinationVC.usage = .edit(predictions[indexPath.row])
        }
    }
}

// MARK: - Table view data source
extension PredictionTableViewController {


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return predictions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cellIdentifier = "PredictionTableViewCell"
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath);
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! PredictionTableViewCell
        cell.configure(with: predictions[indexPath.row])
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let resolveAction  = UITableViewRowAction(style: .normal, title: "Resolve") { (rowAction, indexPath) in
            print("Share Button tapped. Row item value = \(self.predictions[indexPath.row])")
            self.displayResolveSheet(indexPath: indexPath)
        }

        let deleteAction  = UITableViewRowAction(style: .default, title: "Delete") { [weak self] (rowAction, indexPath) -> Void in
            guard let vc = self else { return }
            print("Delete Button tapped. Row item value = \(vc.predictions[indexPath.row])")

            var group = vc.predictionGroup
            group.predictions.remove(at: indexPath.row)
            vc.storage.predictionGroup = group
        }
        resolveAction.backgroundColor = UIColor.init(red: 0, green: 1, blue: 0, alpha: 0.49)
        return [resolveAction,deleteAction]
    }


    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

}


fileprivate extension PredictionTableViewController {

    func displayResolveSheet(indexPath: IndexPath)
    {
        func updateState(prediction: Prediction, state: Prediction.State) {
//            prediction.state = state
            self.setEditing(false, animated: true)
        }

        let alertController = UIAlertController(title: "Resolve", message: "Prediction was:", preferredStyle: .actionSheet)

        let correctButton = UIAlertAction(title: "Correct", style: .default, handler: { (action) -> Void in
//            self.predictions[indexPath.row].state = .correct
//            self.savePredictions()
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//            self.setEditing(false, animated: true)
        })

        let incorrectButton = UIAlertAction(title: "Incorrect", style: .default, handler: { (action) -> Void in
//            self.predictions[indexPath.row].state = .incorrect
//            self.savePredictions()
//            self.tableView.reloadData()
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//            self.setEditing(false, animated: true)
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
            self.setEditing(false, animated: true)
        })

        alertController.addAction(correctButton)
        alertController.addAction(incorrectButton)
        alertController.addAction(cancelButton)

        self.navigationController!.present(alertController, animated: true, completion: nil)
    }


}
