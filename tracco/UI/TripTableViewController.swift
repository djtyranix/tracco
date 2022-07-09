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
    var tableView: UITableView? { get }
    var summarySegueIdentifier: String? { get }
}

class TripTableViewController: UIViewController, TripTableViewControllerProvider
{
    var dataSource: [TripModel]?
    var selectedIndex: IndexPath?
    
    var tableView: UITableView? { get { return nil } }
    var summarySegueIdentifier: String? { get { return nil } }
    
    override func viewDidLoad()
    {
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
            vc.title = "History Detail"
            vc.isFromHistory = true
            
            guard let selectedIndex = selectedIndex,
                  let dataSource = dataSource,
                  let cell = tableView?.cellForRow(at: selectedIndex) as? HistoryTableViewCell
            else { return }
            
            let dataIndex = getDataIndex(selectedIndex.row, data: dataSource)
            let data = dataSource[dataIndex]
            
            vc.viewModel = SummaryHistoryVM(data)
            vc.viewModel?.title = "Trip from \(cell.descriptionLabel.text!)"
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
        guard let summarySegueIdentifier = summarySegueIdentifier
        else { return }
        
        selectedIndex = indexPath
        performSegue(withIdentifier: summarySegueIdentifier, sender: self)
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
