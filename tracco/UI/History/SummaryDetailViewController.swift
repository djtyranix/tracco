//
//  SummaryDetailViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 14/06/22.
//

import UIKit

class SummaryDetailViewController: UIViewController
{
    public var viewModel: SummaryVM?
    
    @IBAction func onCloseButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? TripDetailViewController
        {
            vc.viewModel = viewModel
            vc.isScrollEnable = true
        }
    }
}
