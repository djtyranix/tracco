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
    
    private var historyDataSource: [TripModel]? = StoredModel.history
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContainerViewHistoryTrip.isHidden   = historyDataSource == nil
        ContainerViewHistoryNoTrip.isHidden = historyDataSource != nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? HistoryTripViewController
        {
            vc.dataSource = historyDataSource
            historyDataSource = []
        }
    }
}
