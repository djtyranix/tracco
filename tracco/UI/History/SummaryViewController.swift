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
    @IBOutlet weak var headerTripContainerView: UIView!
    @IBOutlet weak var headerHistoryContainerView: UIView!
    
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
    
    public var viewModel: SummaryVM? { didSet {
        if (viewModelHistory == nil) { refViewModel = viewModel }
    }}
    public var viewModelHistory: SummaryHistoryVM? { didSet {
        refViewModel = viewModelHistory
    }}
    
    // either reference to viewModel (trip) or viewModelHistory
    // this vc will favor history if both are set
    private var refViewModel: SummaryVM?
    
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if (viewModelHistory != nil)
        {
            headerTripContainerView.isHidden = true
            headerHistoryContainerView.isHidden = false
        }
        else
        {
            headerTripContainerView.isHidden = false
            headerHistoryContainerView.isHidden = true
        }
        layoutTripDetail()
        updateViewWithModel()
    }
    
    @IBAction func onCheckTransportMoovitButton(_ sender: UIButton)
    {
        guard let firstModel    = refViewModel?.tripDetailContents.first,
              let lastModel     = refViewModel?.tripDetailContents.last,
              let transitDate   = refViewModel?.tripDetailContents.first?.date
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
        currentTransportCarbonCardView.value    = refViewModel?.currentCarbonEmissionInKgText
        currentTransportCostCardView.value      = refViewModel?.currentCostInIDRText
        otherTransportCostCardView.value        = refViewModel?.otherCostInIDRText
        otherTransportCarbonCardView.value      = refViewModel?.otherCarbonEmissionInKgText
    }
    
    private func layoutTripDetail()
    {
        let noTransit = refViewModel?.tripDetailContents.count ?? 0 <= 2
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
            vc.viewModel = refViewModel
            vc.isScrollEnable = false
        }
        if let vc = segue.destination as? SummaryDetailViewController
        {
            vc.viewModel = refViewModel
        }
        if let vc = segue.destination as? SummaryHeaderHistoryViewController
        {
            vc.viewModel = viewModelHistory
        }
    }

}
