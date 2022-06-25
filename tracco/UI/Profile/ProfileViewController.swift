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
    
    private var model: ProfileModel? = StoredModel.profile
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.model                      = StoredModel.profile
        emptySumProfileView.isHidden    = model != nil
        sumProfileView.isHidden         = model == nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SumProfileViewController
        {
            guard let model = model
            else { return }
            vc.model = model
            self.model = nil
        }
    }
}
