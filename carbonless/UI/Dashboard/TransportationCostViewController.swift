//
//  TransportationCostViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol TransportationCostViewControllerDelegate: AnyObject
{
    @objc optional func onConfirmCost(_ cost: Int)
}

class TransportationCostViewController: UIViewController
{
    public weak var delegate: TransportationCostViewControllerDelegate?
    
    public init()
    {
        super.init(nibName: "TransportationCostViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func onConfirmButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmCost?(0)
    }
}

extension TransportationCostViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
