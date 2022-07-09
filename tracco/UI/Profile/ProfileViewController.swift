//
//  ProfileViewController.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit

class ProfileViewController: UIViewController
{
    @IBOutlet weak var emptySumProfileView: UIView!
    @IBOutlet weak var sumProfileView: UIView!
    
    private var isAlreadyHavingTrip: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Profile"
        
        sumProfileView.isHidden         = !isAlreadyHavingTrip
        emptySumProfileView.isHidden    = isAlreadyHavingTrip
        
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // embedded view controller will be called before viewDidLoad
        if let vc = segue.destination as? SumProfileViewController
        {
            // initialize data here, this will handle if this current view
            // is not loaded but already initialized (init)
            let model           = StoredModel.profile
            isAlreadyHavingTrip = model != nil
            vc.model            = model
        }
    }
}

extension ProfileViewController: GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    {
        sumProfileView.isHidden = false
        emptySumProfileView.isHidden = true
        GlobalPublisher.removeObserver(self)
    }
}
