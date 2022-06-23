//
//  SummaryHeaderHistoryViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import UIKit

class SummaryHeaderHistoryViewController: UIViewController
{
    @IBOutlet weak var tripOverviewLabel: UILabel!
    @IBOutlet weak var tripDescriptionLabel: UILabel!
    
    public var viewModel: SummaryHistoryVM?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tripOverviewLabel.text = viewModel?.headerOverviewText
    }
}
