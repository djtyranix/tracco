//
//  ChooseTransportationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol ChooseTransportationViewControllerDelegate: AnyObject
{
    @objc optional func onConfirmChoose(_ selected: TransportRadioButton?)
}

class ChooseTransportationViewController: ChooseChangeTransportBase<ChooseTransportationViewController>
{
    public weak var delegate: ChooseTransportationViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        super.layoutScrollView(scrollView)
    }

    @IBAction func onConfirmChanges(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmChoose?(radioButton?.selected)
    }
}
