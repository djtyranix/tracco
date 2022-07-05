//
//  HomeNoTripViewController.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

class HomeNoTripViewController: UIViewController
{
    enum Segue: String { case onPlanTrip = "onPlanTripSegue", onTrip = "onTripSegue" }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackButton: UIButton!
    
    private var alertNotifier: LocationPermissionAlertNotifier!
    
    override func viewDidLoad()
    {
        GlobalPublisher.addObserver(self)
        alertNotifier = LocationPermissionAlertNotifier(parent: self)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        titleLabel.text = PartsOfDay.greetingText(PartsOfDay.now())
        super.viewWillAppear(animated)
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
}

extension HomeNoTripViewController: GlobalEvent
{
    func onTripStarted()
    {
        trackButton.isEnabled = false
    }
    
    func onTripEnded()
    {
        trackButton.isEnabled = true
    }
}
