//
//  HistoryTripViewController.swift
//  tracco
//
//  Created by michael wijaya on 20/06/22.
//

import UIKit

class HistoryTripViewController: TripTableViewController
{
    @IBOutlet weak var outletTableView: UITableView!
    
    override var tableView: UITableView? { get { outletTableView } }
    override var summarySegueIdentifier: String? { get { "summarySegue" } }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GlobalPublisher.addObserver(self)
        AnimTabBarController.shared?.observeAdjustment(self)
    }
}

extension HistoryTripViewController: GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    {
        if (dataSource == nil) { dataSource = [] }
        dataSource?.append(model)
        outletTableView.reloadData()
    }
    
    func tripModelUpdated(_ model: TripModel)
    {
        if let dataSource = dataSource,
           let dataIndex = dataSource.firstIndex(where: { $0.id == model.id })
        {
            self.dataSource?[dataIndex] = model
            let tableIndex = getTableIndex(dataIndex, data: dataSource)
            let tableIndexPath = IndexPath(row: tableIndex, section: 0)
            outletTableView.reloadRows(at: [tableIndexPath], with: .automatic)
        }
    }
}
