//
//  HistoryTripViewController.swift
//  tracco
//
//  Created by michael wijaya on 20/06/22.
//

import UIKit

class HistoryTripViewController: UIViewController
{
    enum Segue: String { case summary = "summarySegue" }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedIndex: IndexPath?
    public var dataSource: [TripModel]?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GlobalPublisher.addObserver(self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.rowHeight = HistoryTableViewCell.cellDesiredHeight
        tableView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: "historyCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
            vc.title = "History Detail"
            guard let selectedIndex = selectedIndex,
                  let model = getData(at: selectedIndex),
                  let cell = tableView.cellForRow(at: selectedIndex) as? HistoryTableViewCell
            else { return }
            vc.viewModelHistory = SummaryHistoryVM(model)
            vc.viewModelHistory?.headerOverviewText = "Trip from \(cell.descriptionLabel.text!)"
        }
    }
    
    private func getData(at index: IndexPath) -> TripModel?
    {
        guard let dataSource = dataSource
        else { return nil }
        let dataIndex = dataSource.count - 1 - index.row
        return dataSource[dataIndex]
    }
}

extension HistoryTripViewController: GlobalEvent
{
    func addTripModel(_ model: TripModel)
    {
        dataSource?.append(model)
        tableView.reloadData()
    }
}

extension HistoryTripViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndex = indexPath
        performSegue(withIdentifier: Segue.summary.rawValue, sender: self)
    }
}

extension HistoryTripViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSource?.count ?? 0
    }
    
    // display from the end -> begin (because we want newest to oldest), we can sort the array
    // but it takes computational work, so let's think different
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let data = getData(at: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryTableViewCell
        else { return UITableViewCell() }
        
        cell.setupCell(data)
        return cell
    }
}
