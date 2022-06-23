//
//  SummaryHeaderTripViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import UIKit

class SummaryHeaderTripViewController: UIViewController
{
    @IBAction func onDoneButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
}
