//
//  HistoryTripViewController.swift
//  tracco
//
//  Created by michael wijaya on 20/06/22.
//

import UIKit

class HistoryTripViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72 + 16
    }
}

extension HistoryTripViewController: UITableViewDelegate
{
    
}

extension HistoryTripViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryTableViewCell
        else { return UITableViewCell() }
        
        cell.dateLabel.text = String(indexPath.row)
        cell.transportImageView.image = TransportType.bus.image
        
        return cell
    }
}
