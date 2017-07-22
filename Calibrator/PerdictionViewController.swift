//
//  PredictionViewController.swift
//  Calibrator
//
//  Created by Alex Humphreys on 28/01/2017.
//  Copyright © 2017 Alex Humphreys. All rights reserved.
//

import UIKit
import os.log

class PredictionViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    enum Usage {
        case add(Prediction)
        case edit(Prediction)
        case none
    }

    
    //MARK: Properties
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var probabilityTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var statePicker: UIPickerView!
    
    var storage: Storage! = nil
    var usage: Usage = .none
    var prediction: Prediction? {
        get {
            switch usage {
            case .add(let p): return p
            case .edit(let p): return p
            case .none: return nil
            }
        }
        set {
            guard let p = newValue else { return }
            switch usage {
            case .add: usage = .add(p)
            case .edit: usage = .edit(p)
            case .none: break
            }
        }
    }

    var pickerData: [Prediction.State] = [
        Prediction.State.pending,
        Prediction.State.correct,
        Prediction.State.incorrect,
        Prediction.State.overdue]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Picker
        self.statePicker.delegate = self
        self.statePicker.dataSource = self

        contentTextField.delegate = self
        probabilityTextField.delegate = self

        // Set up views if editing an existing Prediction
        contentTextField.text = prediction?.content ?? ""
        probabilityTextField.text = String(prediction?.probability ?? 0)
        navigationItem.title = prediction?.asTitle() ?? ""
        self.statePicker.selectRow(pickerData.index(of: prediction?.state ?? .pending)!, inComponent: 0, animated: false)
        updateSaveButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard
            contentTextField == contentTextField,
            probabilityTextField == probabilityTextField,
            statePicker == statePicker,
            var p = prediction
            else { return }
        let probValue = Int(probabilityTextField.text ?? "")
        p.content = contentTextField.text ?? ""
        p.probability = probValue ?? 50
        p.state = pickerData[statePicker.selectedRow(inComponent: 0)]

        prediction = p
        updateSaveButtonState()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        updateSaveButtonState()
    }
    //MARK: UIPickerViewDelegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func saveOrAdd(_ sender: UIBarButtonItem) {
        contentTextField.resignFirstResponder()
        probabilityTextField.resignFirstResponder()
        switch usage {
        case .add(let p):
            var group = storage.predictionGroup
            group.predictions.append(p)
            storage.predictionGroup = group
        case .edit(let p):
            var group = storage.predictionGroup
            let newPredictions = group.predictions.map({ (prediction) -> Prediction in
                return prediction.identifier == p.identifier ? p : prediction
            })
            group.predictions = newPredictions
            storage.predictionGroup = group
        case .none: break
        }
        let _ = navigationController?.popViewController(animated: true)
    }

    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = contentTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

