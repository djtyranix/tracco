//
//  SumProfileViewController.swift
//  tracco
//
//  Created by Fannisa Rahmah on 20/06/22.
//

import UIKit

class SumProfileViewController: UIViewController
{
    enum Segue: String { case share = "shareOptionSegue" }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var distanceCard: CardInfoView!
    @IBOutlet weak var mostUsedTransportCard: CardInfoView!
    @IBOutlet weak var trackCountCard: CardInfoView!
    @IBOutlet weak var spendCostCard: CardInfoView!
    @IBOutlet weak var carbonEmissionCard: LongCardInfoView!
    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var encouragementLabel: UILabel!
    @IBOutlet weak var contentCardTrailingConstraint: NSLayoutConstraint!
    
    private var reduceCarbonCard: ReduceCarbonConciseCardView!
    private var reduceCarbonFullCard: ReduceCarbonCardView!
    
    public var model: ProfileModel?
    private var snapshot: UIImage?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GlobalPublisher.addObserver(self)
        reduceCarbonCard        = ReduceCarbonConciseCardView()
        reduceCarbonFullCard    = ReduceCarbonCardView()
        setupHeaderCardView(reduceCarbonCard)
        setupHeaderCardView(reduceCarbonFullCard)
        updateViewWithModel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? ShareOptionViewController
        {
            vc.title = "Share Option"
            vc.image = snapshot
        }
    }
    
    @IBAction func onShareButton(_ sender: UIButton)
    {
        let vc = ShareViewController(nibName: "ShareViewController", bundle: nil)
        // set style default always on light mode
        self.overrideUserInterfaceStyle = .light
        // even though snapshot was captured on different devices
        // it still produce the same dimension of photo
        let contentWidth: CGFloat = contentCardView.bounds.width
        let desiredWidth: CGFloat = 358
        let adjustmentWidth: CGFloat = contentWidth - desiredWidth
        // adjust the constraint
        contentCardTrailingConstraint.constant += adjustmentWidth
        contentCardView.layoutIfNeeded()
        // get the snapshot of current content view
        vc.imageContent = contentCardView.snapshot()
        // revert back to original
        contentCardTrailingConstraint.constant -= adjustmentWidth
        self.overrideUserInterfaceStyle = .unspecified
        // start capturing the screen after view did appear to wait for scroll view
        vc.onViewDidAppear = { [unowned self] in
            // scroll view needs to be removed to be able to capture offscreen
            vc.scrollView.removeFromSuperview()
            self.snapshot = vc.snapshot()
            self.performSegue(withIdentifier: Segue.share.rawValue, sender: self)
            vc.dismiss(animated: true)
        }
        present(vc, animated: true)
    }
    
    private func updateViewWithModel()
    {
        headerView?.removeFromSuperview()
        
        guard let model = model
        else { return }
        
        let viewModel               = ProfileVM(model)
        distanceCard.value          = viewModel.distanceInKmText
        spendCostCard.value         = viewModel.spendCostInIDRText
        trackCountCard.value        = viewModel.trackCountText
        mostUsedTransportCard.value = viewModel.mostUsedTransportText
        carbonEmissionCard.value    = viewModel.totalCarbonEmissionText
        encouragementLabel.text     = viewModel.encouragementText
        
        let heightConstant: CGFloat
        let headerView: UIView
        
        if let treesOffsettingText = viewModel.treesOffsettingText
        {
            reduceCarbonFullCard.carbonValue = viewModel.carbonEmissionReducedInKgText
            reduceCarbonFullCard.treesValue = treesOffsettingText
            
            heightConstant = 174
            headerView = reduceCarbonFullCard
            reduceCarbonCard.removeFromSuperview()
        }
        else
        {
            reduceCarbonCard.value = viewModel.carbonEmissionReducedInKgText
            
            heightConstant = 142
            headerView = reduceCarbonCard
            reduceCarbonFullCard.removeFromSuperview()
        }
        
        let isHeaderAlreadyDisplayed = headerView.superview != nil
        if (isHeaderAlreadyDisplayed) { return }
        
        contentCardView.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: heightConstant),
            headerView.topAnchor.constraint(equalTo: contentCardView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentCardView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentCardView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: carbonEmissionCard.topAnchor, constant: -16)
        ])
    }
    
    private func setupHeaderCardView(_ view: ReduceCarbonConciseCardView?)
    {
        view?.labelColor = UIColor(named: "MainGreen80")
        view?.image = UIImage(named: "Trees")
        setupHeaderCommonView(view)
    }
    
    private func setupHeaderCardView(_ view: ReduceCarbonCardView?)
    {
        view?.labelColor = UIColor(named: "MainGreen80")
        view?.image = UIImage(named: "Trees")
        setupHeaderCommonView(view)
    }
    
    private func setupHeaderCommonView(_ view: UIView?)
    {
        view?.translatesAutoresizingMaskIntoConstraints = false
        view?.layer.cornerRadius = 4
        view?.backgroundColor = UIColor(named: "MainGreen10")
    }
}

extension SumProfileViewController: GlobalEvent
{
    func profileModelUpdated(_ model: ProfileModel)
    {
        self.model = model
        updateViewWithModel()
    }
}

extension SumProfileViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.y > 1
        {
            self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.label]
        }
        else
        {
            self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.clear]
        }
    }
}
