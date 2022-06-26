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
    
    @IBOutlet weak var encouragementLabel: UILabel!
    @IBOutlet weak var carbonEmissionCard: CardInfoView!
    @IBOutlet weak var mostUsedTransportCard: CardInfoView!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    public var historyDataSource: [TripModel]?
    public var profileModel: ProfileModel?
    
    // data max will adjust according to the device table view height
    // this view will only contain just a few latest history
    private var dataMaxSize: Int!
    // last item in the array are the newest, first item are the oldest
    private var dataSource: [TripModel]?
    private var selectedIndex: IndexPath?
    private var isTableViewDataSourceInitialized = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        GlobalPublisher.addObserver(self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.rowHeight = HistoryTableViewCell.cellDesiredHeight
        tableView.register(HistoryTableViewCell.nib, forCellReuseIdentifier: "historyCell")
        
        updateViewWithModel()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        limitLatestTripBasedOnDeviceHeight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
            vc.title = "Latest Trip Detail"
            guard let selectedIndex = selectedIndex,
                  let model = getData(at: selectedIndex),
                  let cell = tableView.cellForRow(at: selectedIndex) as? HistoryTableViewCell
            else { return }
            vc.viewModelHistory = SummaryHistoryVM(model)
            vc.viewModelHistory?.headerOverviewText = "Trip from \(cell.descriptionLabel.text!)"
        }
    }
    
    @IBAction func onViewAllButton(_ sender: UIButton)
    {
        self.tabBarController?.selectedIndex = 1
    }
    
    private func updateViewWithModel()
    {
        guard let model = profileModel
        else { return }
        
        let viewModel = DashboardVM(model)
        encouragementLabel.text = viewModel.encouragementText
        carbonEmissionCard.value = viewModel.carbonEmissionValueText
        mostUsedTransportCard.value = viewModel.mostUsedTransportText
    }
    
    private func limitLatestTripBasedOnDeviceHeight()
    {
        if isTableViewDataSourceInitialized { return }
        let tableViewHeight = tableView.bounds.size.height
        let contentSize = HistoryTableViewCell.cellDesiredHeight
        dataMaxSize = Int(ceil(tableViewHeight / contentSize))
        // get the data from the back because the newest are push to the back
        // reserve capacity to be equal with maximum size
        var arr: [TripModel] = []
        arr.reserveCapacity(dataMaxSize)
        if let newest = historyDataSource?.suffix(dataMaxSize)
        {
            arr.append(contentsOf: newest)
        }
        self.dataSource = arr
        self.historyDataSource = nil
        isTableViewDataSourceInitialized = true
    }
    
    private func getData(at index: IndexPath) -> TripModel?
    {
        guard let dataSource = dataSource
        else { return nil }
        let dataIndex = dataSource.count - 1 - index.row
        return dataSource[dataIndex]
    }
}

extension HomeTripViewController: GlobalEvent
{
    func addTripModel(_ model: TripModel)
    {
        model.forEach { self.profileModel?.add($0) }
        updateViewWithModel()
        // if full, remove the oldest data
        let isFull = dataSource?.count == dataMaxSize
        if (isFull) { dataSource?.removeFirst() }
        // append the newest data and reload table
        dataSource?.append(model)
        tableView.reloadData()
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
        guard let data = getData(at: indexPath),
              let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as? HistoryTableViewCell
        else { return UITableViewCell() }
        
        cell.setupCell(data)
        return cell
    }
}
