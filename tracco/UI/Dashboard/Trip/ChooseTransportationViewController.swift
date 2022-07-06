//
//  ChooseTransportationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol ChooseTransportationViewControllerDelegate: AnyObject
{
    @objc optional func onCancelChoose()
    @objc optional func onConfirmChoose(_ selected: TransportRadioButton?)
}

class ChooseTransportationViewController: ChooseChangeTransportBase<ChooseTransportationViewController>
{
    public weak var delegate: ChooseTransportationViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        super.layoutScrollView(scrollView)
        confirmButton.isEnabled = radioButton?.selected != nil
    }
    
    override func onRadioButtonSelected(_ sender: TransportRadioButton)
    {
        super.onRadioButtonSelected(sender)
        confirmButton.isEnabled = true
    }
    
    @IBAction func onCancelChoose(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onCancelChoose?()
    }

    @IBAction func onConfirmChanges(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmChoose?(radioButton?.selected)
    }
}
