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
    
    private var model: ProfileModel?
    private var isAlreadyHavingTrip: Bool
    
    required init?(coder: NSCoder)
    {
        model = StoredModel.profile
        isAlreadyHavingTrip = model != nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sumProfileView.isHidden         = !isAlreadyHavingTrip
        emptySumProfileView.isHidden    = isAlreadyHavingTrip
        
        if (isAlreadyHavingTrip == false) { GlobalPublisher.addObserver(self) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SumProfileViewController
        {
            vc.model = model
            self.model = nil
        }
    }
}

extension ProfileViewController: GlobalEvent
{
    func addTripModel(_ model: TripModel)
    {
        sumProfileView.isHidden = false
        emptySumProfileView.isHidden = true
        GlobalPublisher.removeObserver(self)
    }
}
