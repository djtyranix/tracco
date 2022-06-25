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
    private var isAlreadyHavingTrip: Bool
    
    required init?(coder: NSCoder)
    {
        historyDataSource = StoredModel.history
        isAlreadyHavingTrip = historyDataSource != nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ContainerViewHistoryTrip.isHidden   = !isAlreadyHavingTrip
        ContainerViewHistoryNoTrip.isHidden = isAlreadyHavingTrip
        
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? HistoryTripViewController
        {
            vc.dataSource = historyDataSource
            historyDataSource = nil
        }
    }
}

extension HistoryViewController: GlobalEvent
{
    func addTripModel(_ model: TripModel)
    {
        ContainerViewHistoryTrip.isHidden = false
        ContainerViewHistoryNoTrip.isHidden = true
        GlobalPublisher.removeObserver(self)
    }
}
