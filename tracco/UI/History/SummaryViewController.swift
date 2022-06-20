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
    @IBOutlet weak var tripDetailView: UIView!
    @IBOutlet weak var tripDetailViewAllButton: UIButton!
    @IBOutlet weak var tripDetailBottomSeparator: UIView!
    @IBOutlet weak var checkTransportMoovitButton: UIButton!
    
    // MARK: view used in comparison
    
    @IBOutlet weak var comparisonLabel: UILabel!
    
    @IBOutlet weak var currentTransportCarbonCardView: CardInfoView!
    @IBOutlet weak var currentTransportCostCardView: CardInfoView!
    
    @IBOutlet weak var otherTransportTitleLabel: UILabel!
    @IBOutlet weak var otherTransportCarbonCardView: CardInfoView!
    @IBOutlet weak var otherTransportCostCardView: CardInfoView!
    
    public var viewModel: SummaryVM?
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        layoutTripDetail()
        updateViewWithModel()
    }
    
    @IBAction func onDoneButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @IBAction func onCheckTransportMoovitButton(_ sender: UIButton)
    {
        guard let firstModel    = viewModel?.tripDetailContents.first,
              let lastModel     = viewModel?.tripDetailContents.last,
              let transitDate   = viewModel?.tripDetailContents.first?.date
        else { return }
        
        if (MoovitAPI.canLink)
        {
            if let directionURL = MoovitAPI.Direction.getDirectionsFrom(
                orig: firstModel.coord,
                origName: viewModel?.tripDetailContents.first?.locationName ?? "X",
                dest: lastModel.coord,
                destName: viewModel?.tripDetailContents.last?.locationName ?? "Y",
                autoRun: true,
                date: transitDate
            )
            {
                UIApplication.shared.open(directionURL)
            }
            else
            {
                print("url moovit not valid")
            }
        }
        else
        {
            UIApplication.shared.open(MoovitAPI.moovitAppDownloadURL)
        }
    }
    
    private func updateViewWithModel()
    {
        currentTransportCarbonCardView.value    = viewModel?.currentCarbonEmissionInKgText
        currentTransportCostCardView.value      = viewModel?.currentCostInIDRText
        otherTransportCostCardView.value        = viewModel?.otherCostInIDRText
        otherTransportCarbonCardView.value      = viewModel?.otherCarbonEmissionInKgText
    }
    
    private func layoutTripDetail()
    {
        let noTransit = viewModel?.tripDetailContents.count ?? 0 <= 2
        if (noTransit)
        {
            tripDetailViewAllButton.isHidden = true
            tripDetailView.bottomAnchor.constraint(equalTo: tripDetailBottomSeparator.topAnchor, constant: -16).isActive = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? TripDetailViewController
        {
            vc.viewModel = viewModel
            vc.isScrollEnable = false
        }
        if let vc = segue.destination as? SummaryDetailViewController
        {
            vc.viewModel = viewModel
        }
    }

}
