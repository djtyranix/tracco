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
    private var isAlreadyHavingTrip: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        noTripView.isHidden     = isAlreadyHavingTrip
        tripView.isHidden       = !isAlreadyHavingTrip
        
        // when trip model is added for the first time, we need to update container view
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    @IBAction func onSettingsButton(_ sender: UIBarButtonItem)
    {
        self.onGoToSettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // embedded view controller will be called before viewDidLoad
        if let vc = segue.destination as? HomeTripViewController
        {
            // initialize data here, this will handle if this current view
            // is not loaded but already initialized (init)
            historyDataSource = StoredModel.history
            profileModel = StoredModel.profile
            isAlreadyHavingTrip = historyDataSource != nil
            
            vc.profileModel = profileModel
            vc.historyDataSource = historyDataSource
            historyDataSource = nil
            profileModel = nil
        }
    }
}

extension DashboardViewController: GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    {
        tripView.isHidden = false
        noTripView.isHidden = true
        // after having a trip, doesn't need to update container view
        GlobalPublisher.removeObserver(self)
    }
}

extension DashboardViewController: AuthorizationSecondaryPlanDelegate
{}
