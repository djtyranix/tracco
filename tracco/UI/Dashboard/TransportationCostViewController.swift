//
//  TransportationCostViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit
import Combine

@objc protocol TransportationCostViewControllerDelegate: AnyObject
{
    @objc optional func onCancelCost()
    @objc optional func onConfirmCost(_ cost: Double)
}

class TransportationCostViewController: UIViewController
{
    public weak var delegate: TransportationCostViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var approxCostSwitch: UISwitch!
    
    public let invalidCostValue = -1.0
    public var viewModel: TransportationCostVM? { didSet { bindViewModel() } }
    
    private var cancellables: [AnyCancellable]?
    
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
        bindViewModel()
    }
    
    private func bindViewModel()
    {
        guard let viewModel = viewModel
        else { return }
        approxCostSwitch.isOn = viewModel.isUsingCostApproximation
        onCostApproximationChanged(approxCostSwitch)
        cancellables = [
            viewModel.$totalCostInIDRText.sink(receiveValue: { [unowned self] in textField.text = $0 })
        ]
    }

    @IBAction func onConfirmButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        
        let cost: Double
        if let costString = textField.text { cost = Double(costString) ?? invalidCostValue }
        else { cost = invalidCostValue }
        
        delegate?.onConfirmCost?(cost)
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onCancelCost?()
    }
    
    @IBAction func onCostApproximationChanged(_ sender: UISwitch)
    {
        let useApproximation = sender.isOn
        textField.clearButtonMode = useApproximation ? .never : .always
        textField.isEnabled = !useApproximation
        viewModel?.isUsingCostApproximation = useApproximation
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
