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
    
    private var historyDataSource: [TripModel]? = nil
    private let viewModel = HistoryViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let count = viewModel.getTripCount()
        
        if count == 0 {
            ContainerViewHistoryTrip.isHidden = true
            ContainerViewHistoryNoTrip.isHidden = false
        } else if count == -1 {
            print("Error fetch")
        } else {
            // There is some trip
            ContainerViewHistoryTrip.isHidden = false
            ContainerViewHistoryNoTrip.isHidden = true
        }
    }
}
