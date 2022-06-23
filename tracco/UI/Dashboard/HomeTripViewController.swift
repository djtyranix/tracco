//
//  HomeTripViewController.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

class HomeTripViewController: UIViewController
{
    enum Segue: String { case summary = "summarySegue"}
    
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    public var historyDataSource: [TripModel]?
    private var dataSource: ArraySlice<TripModel>?
    private var selectedIndex: IndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = HistoryTableViewCell.cellDesiredHeight
        tableView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: "historyCell")
        
        setTrackingButtonFont()
    }
    
    override func viewDidLayoutSubviews()
    {
        limitLatestTripBasedOnDeviceHeight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
            vc.title = "Latest Trip Detail"
            guard let selectedIndex = selectedIndex,
                  let model = dataSource?[selectedIndex.row],
                  let cell = tableView.cellForRow(at: selectedIndex) as? HistoryTableViewCell
            else { return }
            vc.viewModelHistory = SummaryHistoryVM(model)
            vc.viewModelHistory?.headerOverviewText = "Trip from \(cell.descriptionLabel.text!)"
        }
    }
    
    private func limitLatestTripBasedOnDeviceHeight()
    {
        let tableViewHeight = tableView.bounds.size.height
        let contentSize = HistoryTableViewCell.cellDesiredHeight
        let roomForRow = Int(ceil(tableViewHeight / contentSize))
        // get the data from the back because the newest are push to the back
        dataSource = historyDataSource?.suffix(roomForRow)
    }
    
    private func setTrackingButtonFont() {
        if #available(iOS 15.0, *) {
            guard var config = trackButton.configuration else {
                return
            }
            
            config.attributedTitle = try! AttributedString( NSAttributedString(string: "Start Tracking", attributes: [
                .font: UIFont(name: "Nunito-Bold", size: 17)!,
            ]), including: AttributeScopes.UIKitAttributes.self
            )
            
            trackButton.configuration = config
        }
    }
}

extension HomeTripViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndex = indexPath
        performSegue(withIdentifier: Segue.summary.rawValue, sender: self)
    }
}

extension HomeTripViewController: UITableViewDataSource
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
        
        let dataIndex = dataSource.endIndex - 1 - indexPath.row
        let data = dataSource[dataIndex]
        
        cell.setupCell(data)
        return cell
    }
}
