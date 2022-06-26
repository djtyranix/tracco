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
    
    private var historyDataSource: [TripModel]?
    private var profileModel: ProfileModel?
    private var isAlreadyHavingTrip: Bool
    
    required init?(coder: NSCoder)
    {
        historyDataSource = StoredModel.history
        profileModel = StoredModel.profile
        isAlreadyHavingTrip = historyDataSource != nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        noTripView.isHidden     = isAlreadyHavingTrip
        tripView.isHidden       = !isAlreadyHavingTrip
        
        // when trip model is added for the first time, we need to update container view
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? HomeTripViewController
        {
            vc.profileModel = profileModel
            vc.historyDataSource = historyDataSource
            historyDataSource = nil
            profileModel = nil
        }
    }
}

extension DashboardViewController: GlobalEvent
{
    func addTripModel(_ model: TripModel)
    {
        tripView.isHidden = false
        noTripView.isHidden = true
        // after having a trip, doesn't need to update container view
        GlobalPublisher.removeObserver(self)
    }
}
