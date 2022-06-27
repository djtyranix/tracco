//
//  HistoryTripViewController.swift
//  tracco
//
//  Created by michael wijaya on 20/06/22.
//

import UIKit

class HistoryTripViewController: TripTableViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.provider = self
        super.viewDidLoad()
        GlobalPublisher.addObserver(self)
    }
}

extension HistoryTripViewController: TripTableViewControllerProvider
{
    func getTableView() -> UITableView { return tableView }
    
    func summarySegueIdentifier() -> String { return "summarySegue" }
}

extension HistoryTripViewController: GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    {
        if (dataSource == nil) { dataSource = [] }
        dataSource?.append(model)
        tableView.reloadData()
    }
    
    func tripModelUpdated(_ model: TripModel)
    {
        if let dataSource = dataSource,
           let dataIndex = dataSource.firstIndex(where: { $0.id == model.id })
        {
            self.dataSource?[dataIndex] = model
            let tableIndex = getTableIndex(dataIndex, data: dataSource)
            let tableIndexPath = IndexPath(row: tableIndex, section: 0)
            tableView.reloadRows(at: [tableIndexPath], with: .automatic)
        }
    }
}
