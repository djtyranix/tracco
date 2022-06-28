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
    
    override func viewDidLoad()
    {
        GlobalPublisher.addObserver(self)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        titleLabel.text = PartsOfDay.greetingText(PartsOfDay.now())
        super.viewWillAppear(animated)
    }
    
    @IBAction func onStartTripButton(_ sender: UIButton)
    {
        let showPlanTrip = StoredModel.showRouteRecommendation ?? true
        let segueTrip: Segue = showPlanTrip ? .onPlanTrip : .onTrip
        performSegue(withIdentifier: segueTrip.rawValue, sender: self)
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
