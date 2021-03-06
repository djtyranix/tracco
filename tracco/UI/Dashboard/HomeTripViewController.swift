//
//  HomeTripViewController.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit
import CoreLocation

class HomeTripViewController: TripTableViewController
{
    enum Segue: String { case onPlanTrip = "onPlanTripSegue", onTrip = "onTripSegue" }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var encouragementLabel: UILabel!
    @IBOutlet weak var carbonEmissionCard: CardInfoView!
    @IBOutlet weak var mostUsedTransportCard: CardInfoView!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var outletTableView: UITableView!
    
    override var tableView: UITableView? { get { outletTableView } }
    override var summarySegueIdentifier: String? { get { "summarySegue" } }
    
    public var greetingTitleText: String?
    public var profileModel: ProfileModel?
    public var historyDataCount: Int = 0
    public var historyDataSource: [TripModel]?
    
    private var alertNotifier: LocationPermissionAlertNotifier!
    // data max will adjust according to the device table view height
    // this view will only contain just a few latest history
    private var dataMaxSize: Int!
    // last item in the array are the newest, first item are the oldest
    private var isTableViewDataSourceInitialized = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        GlobalPublisher.addObserver(self)
        alertNotifier = LocationPermissionAlertNotifier(parent: self)
        AnimTabBarController.shared?.observeAdjustment(self)
        
        updateViewWithModel()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        titleLabel.text = PartsOfDay.greetingText(PartsOfDay.now())
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        limitLatestTripBasedOnDeviceHeight()
    }
    
    @IBAction func onStartTripButton(_ sender: UIButton)
    {
        if StoredModel.showRouteRecommendation ?? true
        {
            performSegue(withIdentifier: Segue.onPlanTrip.rawValue, sender: self)
        }
        else if alertNotifier.isAbleToTrack
        {
            performSegue(withIdentifier: Segue.onTrip.rawValue, sender: self)
        }
        else
        {
            alertNotifier.requestPermission()
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
        let tableViewHeight = outletTableView.bounds.size.height
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
        self.historyDataCount = historyDataSource?.count ?? 0
        self.historyDataSource = nil
        isTableViewDataSourceInitialized = true
    }
}

extension HomeTripViewController: GlobalEvent
{
    func onTripStarted()
    {
        trackButton.isEnabled = false
    }
    
    func onTripEnded()
    {
        trackButton.isEnabled = true
    }
    
    func tripModelAdded(_ model: TripModel)
    {
        historyDataCount += 1
        // if full, remove the oldest data
        let isFull = dataSource?.count == dataMaxSize
        if (isFull) { dataSource?.removeFirst() }
        // append the newest data and reload table
        dataSource?.append(model)
        outletTableView.reloadData()
    }
    
    func profileModelUpdated(_ model: ProfileModel)
    {
        self.profileModel = model
        updateViewWithModel()
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
