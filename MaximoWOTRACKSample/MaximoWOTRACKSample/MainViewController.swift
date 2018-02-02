//
//  MainViewController.swift
//  MaximoWOTRACKSample
//
//  Created by Silvino Vieira de Vasconcelos Neto on 02/02/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _activityIndicator: UIActivityIndicatorView!

    var workOrders : [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _activityIndicator.hidesWhenStopped = true;
        _activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        _activityIndicator.center = view.center;
        _activityIndicator.startAnimating()
        view.addSubview(_activityIndicator)
        _tableView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        loadWorkOrders()
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.reloadData()
        _tableView.isHidden = false
        _activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (workOrders != nil) {
            return workOrders!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self._tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = (self.workOrders![indexPath.row]["description"] as! String)
        return cell
    }

    func loadWorkOrders() {
        do {
            workOrders = try MaximoAPI.shared().listWorkOrders()
        }
        catch {
            let alert = UIAlertController(title: "Error", message: "An error occurred while loading Work Orders from the server", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
