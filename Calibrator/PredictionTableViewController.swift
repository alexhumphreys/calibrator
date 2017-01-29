//
//  PredictionTableViewController.swift
//  Calibrator
//
//  Created by Alex Humphreys on 29/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit
import os.log

class PredictionTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var predictions = [Prediction]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedPredictions = loadPredictions() {
            predictions += savedPredictions
        } else {
            loadSamplePredictions()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PredictionTableViewCell else {
            fatalError("The dequeued cell is not an instance of PredictionTableViewCell.")
        }
        
        let prediction = predictions[indexPath.row]
        
        cell.contentLabel.text = prediction.content
        cell.probabilityLabel.text = String(prediction.probability)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            predictions.remove(at: indexPath.row)
            savePredictions()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new prediction.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let predictionDetailViewController = segue.destination as? PredictionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedPredictionCell = sender as? PredictionTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedPredictionCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPrediction = predictions[indexPath.row]
            predictionDetailViewController.prediction = selectedPrediction
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

    //MARK: Actions
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PredictionViewController, let prediction = sourceViewController.prediction {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                predictions[selectedIndexPath.row] = prediction
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: predictions.count, section: 0)
                predictions.append(prediction)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            savePredictions()
        }
    }
    
    //MARK: Private Methods
    
    private func loadSamplePredictions() {
        let prediction1  = Prediction(content: "X will win sport", probability: 70)
        let prediction2  = Prediction(content: "X will increase in value", probability: 60)
        
        predictions += [prediction1, prediction2]
    }
    
    private func savePredictions() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(predictions, toFile: Prediction.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadPredictions() -> [Prediction]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Prediction.ArchiveURL.path) as? [Prediction]
    }
}
