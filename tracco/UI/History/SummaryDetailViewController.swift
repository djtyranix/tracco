//
//  SummaryDetailViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 14/06/22.
//

import UIKit

class SummaryDetailViewController: UIViewController
{
    @IBOutlet weak var tripDetailView: TripDetailView!
    
    public var modelToDisplay: [TransitModel] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tripDetailView.model = modelToDisplay
        modelToDisplay = []
    }
    
    @IBAction func onCloseButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
}
