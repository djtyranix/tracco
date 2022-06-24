//
//  SumProfileViewController.swift
//  tracco
//
//  Created by Fannisa Rahmah on 20/06/22.
//

import UIKit

class SumProfileViewController: UIViewController
{
    @IBOutlet weak var totalCarbonCard: TotalCarbonProfileCard!
    @IBOutlet weak var distanceCard: CardInfoView!
    @IBOutlet weak var mostUsedTransportCard: CardInfoView!
    @IBOutlet weak var trackCountCard: CardInfoView!
    @IBOutlet weak var spendCostCard: CardInfoView!
    
    public var viewModel: ProfileVM?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        totalCarbonCard.value       = viewModel?.totalCarbonEmissionText
        distanceCard.value          = viewModel?.distanceInKmText
        spendCostCard.value         = viewModel?.spendCostInIDRText
        trackCountCard.value        = viewModel?.trackCountText
        mostUsedTransportCard.value = viewModel?.mostUsedTransportText
    }
}
