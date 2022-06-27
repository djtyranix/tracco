//
//  HomeNoTripViewController.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

class HomeNoTripViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var trackButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        titleLabel.text = PartsOfDay.greetingText(PartsOfDay.now())
    }
}
