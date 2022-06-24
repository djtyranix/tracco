//
//  ViewController.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit

class DashboardViewController: UIViewController
{
    @IBOutlet weak var noTripView: UIView!
    @IBOutlet weak var tripView: UIView!
    
    let viewModel = DashboardViewModel()
    
    private var historyDataSource: [TripModel]?
    
    private var isAlreadyHavingTrip: Bool!
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        historyDataSource = StoredModel.history
        isAlreadyHavingTrip = historyDataSource != nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        noTripView.isHidden     = isAlreadyHavingTrip
        tripView.isHidden       = !isAlreadyHavingTrip
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? HomeTripViewController
        {
            vc.historyDataSource = historyDataSource
            historyDataSource = nil
        }
    }
}

