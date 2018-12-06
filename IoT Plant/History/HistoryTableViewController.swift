//
//  HistoryTableViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 23/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit


class HistoryTableViewController: UITableViewController {

    var humidityList: [String] = []
    var pullToRefresh = UIRefreshControl()
    var plantData: PlantModel?
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get humidity from Firebasexw
        PlantDAO.getHumidityHisotry(plantName: plantName ?? "", callback: {(history) -> Void in
            self.humidityList = history
            self.tableView.reloadData()
        })
        
        
        //Handles Pull to Refresh
        pullToRefresh.addTarget(self, action: #selector(HistoryTableViewController.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(pullToRefresh)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        // Empty tableView
        humidityList.removeAll()
        self.tableView.reloadData()
        //Gets data from Firebase
        PlantDAO.getHumidityHisotry(plantName: plantName ?? "", callback: {(history) -> Void in
            self.humidityList = history
            self.tableView.reloadData()
        })
        
        self.pullToRefresh.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return humidityList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTable", for: indexPath) as! HistoryTableViewCell
        cell.humidityLabel?.text = humidityList[indexPath.row]
        return cell
    }
}

var plantName: String?
