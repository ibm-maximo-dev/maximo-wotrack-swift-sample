//
//  FormViewController.swift
//  MaximoWOTRACKSample
//
//  Created by Silvino Vieira de Vasconcelos Neto on 07/02/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit
import MaximoRESTSDK

extension UITextField {
    func loadDropdownData(data: [String], selectedItem: String) {
        self.inputView = StatusPickerView(pickerData: data, selectedItem: selectedItem, dropdownField: self)
    }
}

class FormViewController: UIViewController {
    
    @IBOutlet weak var _workOrder: UITextField!
    @IBOutlet weak var _duration: UITextField!
    @IBOutlet weak var _description: UITextField!
    @IBOutlet weak var _scheduleStart: UITextField!
    @IBOutlet weak var _scheduleFinish: UITextField!
    @IBOutlet weak var _saveButton: UIButton!
    @IBOutlet weak var _status: UITextField!
    
    @IBOutlet weak var deleteButton: RoundedButton!
    var selectedWorkOrder : [String: Any]?
    var selectedDateField : String?
    var scheduleStart : Date?
    var scheduleFinish : Date?
    var isNew : Bool = true
    var statusList : [[String: Any]] = []
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _scheduleStart.addTarget(self, action: #selector(showDateTimePicker), for: UIControlEvents.touchDown)
        _scheduleFinish.addTarget(self, action: #selector(showDateTimePicker), for: UIControlEvents.touchDown)
        _saveButton.addTarget(self, action: #selector(saveWorkOrder), for: UIControlEvents.touchUpInside)

        var statusDescription = "Waiting on Approval"
        if selectedWorkOrder != nil {
            isNew = false
            _workOrder.text = selectedWorkOrder!["wonum"] as? String
            _description.text = selectedWorkOrder!["description"] as? String
            _duration.text = String(selectedWorkOrder!["estdur"] as! Double)
            statusDescription = self.selectedWorkOrder!["status_description"] as! String
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if (selectedWorkOrder!["schedstart"] != nil) {
                scheduleStart = dateFormatter.date(from: selectedWorkOrder!["schedstart"] as! String)
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                _scheduleStart.text = dateFormatter.string(from: scheduleStart!)
            }
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if (selectedWorkOrder!["schedfinish"] != nil) {
                scheduleFinish = dateFormatter.date(from: selectedWorkOrder!["schedfinish"] as! String)
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                _scheduleFinish.text = dateFormatter.string(from: scheduleFinish!)
            }
            _status.isUserInteractionEnabled = true
        }
        
        do {
            statusList = try MaximoAPI.shared().listWorkOrderStatuses()
            var stringList : [String] = []
            var i = 0
            while (i < statusList.count) {
                var domainValue = statusList[i]
                stringList.append(domainValue["description"] as! String)
                i += 1
            }
            
            _status.loadDropdownData(data: stringList, selectedItem: statusDescription)
        }
        catch {
            //TODO: Show error message.
        }

        
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Work Order"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buildWorkOrder() -> [String: Any] {
        if isNew {
            selectedWorkOrder = [:]
            selectedWorkOrder!["wonum"] = _workOrder.text
            selectedWorkOrder!["siteid"] = MaximoAPI.shared().loggedUser["locationsite"]
            selectedWorkOrder!["orgid"] = MaximoAPI.shared().loggedUser["locationorg"]
        }

        selectedWorkOrder!["description"] = _description.text
        selectedWorkOrder!["estdur"] = Double(_duration.text!)
        
//        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        if scheduleStart != nil {
            selectedWorkOrder!["schedstart"] = dateFormatter.string(from: scheduleStart!)
        }
        if scheduleFinish != nil {
            selectedWorkOrder!["schedfinish"] = dateFormatter.string(from: scheduleFinish!)
        }

        let statusPicker = _status.inputView as! StatusPickerView
        let selectedStatus = statusList[statusPicker.selectedRow]
        selectedWorkOrder!["status"] = selectedStatus["maxvalue"]
        selectedWorkOrder!["status_description"] = selectedStatus["description"]
        return selectedWorkOrder!
    }
    
    func figureOutDuration() -> Void {
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        if let start = scheduleStart, let end = scheduleFinish {
            let duration = end.timeIntervalSince(start) / 60 // duration in minutes
            _duration.text = duration.description
        }
        else {
            _duration.text = ""
        }
    }
    @objc func showDateTimePicker(sender: UITextField) {
        selectedDateField = sender.placeholder
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        sender.inputView = datePickerView
        if selectedDateField! == "Schedule Start" && scheduleStart != nil{
            datePickerView.date = scheduleStart!
        }
        else if scheduleFinish != nil {
            datePickerView.date = scheduleFinish!
        }
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {
//        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        if selectedDateField! == "Schedule Start" {
            scheduleStart = sender.date
            _scheduleStart.text = dateFormatter.string(from: sender.date)
            _scheduleStart.resignFirstResponder()
        }
        else {
            scheduleFinish = sender.date
            _scheduleFinish.text = dateFormatter.string(from: sender.date)
            _scheduleFinish.resignFirstResponder()

        }
        // Set duration field
        figureOutDuration()
        guard sender.isHidden == false else {
            return
        }
        sender.isHidden = true
    }

    @objc func saveWorkOrder() {
        let workOrder = buildWorkOrder()
        do {
            if isNew {
                try MaximoAPI.shared().createWorkOrder(workOrder: workOrder)
            }
            else {
                try MaximoAPI.shared().updateWorkOrder(workOrder: workOrder)
            }

            let alert = UIAlertController(title: "Info", message: "Work Order successfully saved.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        catch let e{
            showAlertWithText(header: "Error", message: e.localizedDescription)
        }
    }
    
    @IBAction func deleteButtonTouched(_ sender: RoundedButton) {
        guard let workorder = selectedWorkOrder else {
            showAlertWithText(header: "Error", message: "No Work Order present")
            return
        }
        do {
            try MaximoAPI.shared().deleteWorkOrder(workOrder: workorder)
        }
        catch OslcError.serverError(let code, let error) {
            showAlertWithText(header: "Error", message: "\(code) : \(error)")
        }
        catch let e {
            showAlertWithText(header: "Error", message: e.localizedDescription)
            print(e)
        }

    }
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        alert.view.tintColor = UIColor.red
        self.present(alert, animated: true, completion: nil)
    }
}
