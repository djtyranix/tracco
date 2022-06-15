//
//  ViewController.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var noTripView: UIView!
    @IBOutlet weak var tripView: UIView!
    
    let viewModel = DashboardViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if viewModel.isAlreadyHavingTrip() {
            noTripView.isHidden = true
            tripView.isHidden = false
        } else {
            noTripView.isHidden = false
            tripView.isHidden = true
        }
    }
}

