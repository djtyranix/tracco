//
//  HistoryViewController.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit

class HistoryViewController: UIViewController
{
    @IBOutlet var ContainerViewHistoryNoTrip: UIView!
    @IBOutlet var ContainerViewHistoryTrip: UIView!
    
    private var historyDataSource: [TripModel]?
    private var isAlreadyHavingTrip: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ContainerViewHistoryTrip.isHidden   = !isAlreadyHavingTrip
        ContainerViewHistoryNoTrip.isHidden = isAlreadyHavingTrip
        
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // embedded segue will be called first before viewDidLoad
        if let vc = segue.destination as? HistoryTripViewController
        {
            // initialize data here, this will handle if this current view
            // is not loaded but already initialized (init)
            historyDataSource = StoredModel.history
            isAlreadyHavingTrip = historyDataSource != nil
            
            vc.dataSource = historyDataSource
            historyDataSource = nil
        }
    }
}

extension HistoryViewController: GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    {
        ContainerViewHistoryTrip.isHidden = false
        ContainerViewHistoryNoTrip.isHidden = true
        GlobalPublisher.removeObserver(self)
    }
}
