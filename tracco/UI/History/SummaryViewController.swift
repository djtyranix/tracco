//
//  SummaryViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 14/06/22.
//

import UIKit
import MapKit

class SummaryViewController: UIViewController
{
    @IBOutlet weak var tripDetailView: TripDetailView!
    @IBOutlet weak var tripDetailViewAllButton: UIButton!
    @IBOutlet weak var tripDetailBottomSeparator: UIView!
    @IBOutlet weak var currentTransportCarbonCardView: CardInfoView!
    @IBOutlet weak var currentTransportCostCardView: CardInfoView!
    @IBOutlet weak var otherTransportCarbonCardView: CardInfoView!
    @IBOutlet weak var otherTransportCostCardView: CardInfoView!
    
    public var modelToDisplay: [TransitModel] = []
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        layoutTripDetail()
        layoutComparison()
    }
    
    @IBAction func onDoneButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func layoutComparison()
    {
        let totalCarbonInKg = modelToDisplay.reduce(0.0, { return $0 + $1.carbonEmissionInKg })
        let totalCostInIDR = modelToDisplay.reduce(0.0, { return $0 + $1.costInIDR })
        
        currentTransportCarbonCardView.value = RoundingDigit(totalCarbonInKg, kind: .number).getString(precision: 1)
        currentTransportCostCardView.value = RoundingDigit(totalCostInIDR, kind: .currency).getString(precision: 1)
    }
    
    private func layoutTripDetail()
    {
        let noTransit = modelToDisplay.count == 1
        tripDetailView.model = modelToDisplay
        tripDetailView.scrollView.isScrollEnabled = false
        if (noTransit)
        {
            tripDetailViewAllButton.isHidden = true
            tripDetailView.bottomAnchor.constraint(equalTo: tripDetailBottomSeparator.topAnchor, constant: -16).isActive = true
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryDetailViewController
        {
            vc.modelToDisplay = modelToDisplay
        }
    }

}
