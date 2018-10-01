//
//  HistoryTableViewController.swift
//  IoT Plant
//
//  Created by Tomas Martins on 23/08/2018.
//  Copyright © 2018 Tomas Martins. All rights reserved.
//

import UIKit
import FirebaseDatabase


class HistoryTableViewController: UITableViewController {

    var humidityList: [String] = []
    var historyReference: DatabaseReference?
    var humidityHandle: DatabaseHandle?
    
    var pullToRefresh = UIRefreshControl()
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get humidity from Firebase
        historyReference = Database.database().reference()
        humidityHandle = historyReference?.child("Plants").child(plantName!).observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String
            if let actualPost = post {
                if (actualPost != "--.-") {
                    self.humidityList.append(actualPost)
                    self.tableView.reloadData()
                }
            }
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
        historyReference = Database.database().reference()
        humidityHandle = historyReference?.child("Plants").child(plantName!).observe(.childAdded, with: { (snapshot) in
            let post = snapshot.value as? String
            if let actualPost = post {
                if (actualPost != "--.-") {
                    self.humidityList.append(actualPost)
                    self.tableView.reloadData()
                }
            }
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

var plantName: String?
