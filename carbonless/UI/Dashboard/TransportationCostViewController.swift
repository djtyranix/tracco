//
//  TransportationCostViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol TransportationCostViewControllerDelegate: AnyObject
{
    @objc optional func onCancelCost()
    @objc optional func onConfirmCost(_ cost: Int)
}

class TransportationCostViewController: UIViewController
{
    public weak var delegate: TransportationCostViewControllerDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
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
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onCancelCost?()
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
