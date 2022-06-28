//
//  SummarizingViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 28/06/22.
//

import UIKit
import Lottie

class SummarizingViewController: UIViewController
{
    enum Segue: String {  case summary = "summarySegue" }
    
    @IBOutlet weak var animationContentView: UIView!
    
    public var modelToSummarize: TripModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LottieFactory.makeIndefiniteLoadingView(on: animationContentView).play()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        performSegue(withIdentifier: Segue.summary.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if modelToSummarize == nil
        {
            self.view.window?.rootViewController?.dismiss(animated: true)
            return
        }
        
        if let vc = segue.destination as? SummaryViewController
        {
            let isNoTrip = StoredModel.profile == nil || StoredModel.history == nil

            var profileModel: ProfileModel = isNoTrip ? ProfileModel() : StoredModel.profile!
            var historyModel: [TripModel] = isNoTrip ? [] : StoredModel.history!
            
            // set model id equal with index in history model
            modelToSummarize!.id = historyModel.count
            
            profileModel.add(modelToSummarize!)
            historyModel.append(modelToSummarize!)

            StoredModel.profile = profileModel
            StoredModel.history = historyModel

            GlobalPublisher.shared.tripModelAdded(modelToSummarize!)
            GlobalPublisher.shared.profileModelUpdated(profileModel)
            
            vc.viewModel = SummaryVM(modelToSummarize!)
            
            modelToSummarize = nil
        }
    }
}
