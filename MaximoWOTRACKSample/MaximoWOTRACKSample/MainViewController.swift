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
    @IBOutlet weak var _listActivityIndicator: UIActivityIndicatorView!
    
    let PAGE_SIZE = 10
    var workOrders : [[String: Any]]?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _activityIndicator.hidesWhenStopped = true
        _activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray
        _activityIndicator.center = view.center
        _activityIndicator.startAnimating()
        view.addSubview(_activityIndicator)
        
        _listActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        _listActivityIndicator.isHidden = true
        view.addSubview(_listActivityIndicator)
        
        _tableView.isHidden = true
        _tableView.numberOfRows(inSection: PAGE_SIZE)
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 40 {
            loadSegment(offset: workOrders!.count, size: PAGE_SIZE-1)
        }
    }

    func loadSegment(offset:Int, size:Int) {
        if (!self.isLoading) {
            self.isLoading = true
            _listActivityIndicator.isHidden = false
            _listActivityIndicator.startAnimating()

            var items : [[String: Any]]?
            DispatchQueue.global().async {
                do {
                    items = try MaximoAPI.shared().nextWorkOrdersPage()
                }
                catch {
                    let alert = UIAlertController(title: "Error", message: "An error occurred while loading Work Orders from the server", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

                DispatchQueue.main.async(execute: {
                    for item in items! {
                        let row = self.workOrders!.count
                        let indexPath = NSIndexPath(row: row, section: 0)
                        self.workOrders?.append(item)
                        self._tableView?.insertRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                    }
                    self.isLoading = false
                    self._listActivityIndicator.stopAnimating()
                    self._listActivityIndicator.isHidden = true
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (workOrders != nil) {
            return workOrders!.count
        }
        return PAGE_SIZE
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
