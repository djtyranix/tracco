//
//  ChangeTransportViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 13/06/22.
//

import UIKit

@objc protocol ChangeTransportViewControllerDelegate: AnyObject
{
    @objc optional func onCancelChange()
    @objc optional func onConfirmChange(_ selected: TransportRadioButton?)
}

class ChangeTransportViewController: ChooseChangeTransportBase<ChangeTransportViewController>
{
    public weak var delegate: ChangeTransportViewControllerDelegate?
    
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

    @IBAction func onConfirmButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmChange?(radioButton?.selected)
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onCancelChange?()
    }
}
