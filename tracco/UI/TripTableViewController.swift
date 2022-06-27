//
//  TripTableViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 27/06/22.
//

import Foundation
import UIKit

protocol TripTableViewControllerProvider: AnyObject
{
    func getTableView() -> UITableView
    func summarySegueIdentifier() -> String
}

class TripTableViewController: UIViewController
{
    var dataSource: [TripModel]?
    var selectedIndex: IndexPath?
    
    weak var provider: TripTableViewControllerProvider?
    
    override func viewDidLoad()
    {
        let tableView = provider?.getTableView()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.delaysContentTouches = false
        tableView?.rowHeight = HistoryTableViewCell.cellDesiredHeight
        tableView?.register(HistoryTableViewCell.nib, forCellReuseIdentifier: "historyCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
            vc.title = "Latest Trip Detail"
            
            guard let selectedIndex = selectedIndex,
                  let dataSource = dataSource,
                  let cell = provider?.getTableView().cellForRow(at: selectedIndex) as? HistoryTableViewCell
            else { return }
            
            let dataIndex = getDataIndex(selectedIndex.row, data: dataSource)
            let data = dataSource[dataIndex]
            
            vc.viewModelHistory = SummaryHistoryVM(data)
            vc.viewModelHistory?.headerOverviewText = "Trip from \(cell.descriptionLabel.text!)"
        }
    }
}

// reverse order between data and table index
extension TripTableViewController
{
    func getDataIndex(_ tableIndex: Int, data: [Any]) -> Int
    {
        return data.count - 1 - tableIndex
    }
    
    func getTableIndex(_ dataIndex: Int, data: [Any]) -> Int
    {
        return data.count - 1 - dataIndex
    }
}

extension TripTableViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndex = indexPath
        if (provider == nil) { return }
        performSegue(withIdentifier: provider!.summarySegueIdentifier(), sender: self)
    }
}

extension TripTableViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSource?.count ?? 0
    }
    
    // display from the end -> begin (because we want newest to oldest), we can sort the array
    // but it takes computational work, so let's think different
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let dataSource = dataSource,
              let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryTableViewCell
        else { return UITableViewCell() }
        
        let dataIndex = getDataIndex(indexPath.row, data: dataSource)
        let data = dataSource[dataIndex]
        cell.setupCell(data)
        
        return cell
    }
}
