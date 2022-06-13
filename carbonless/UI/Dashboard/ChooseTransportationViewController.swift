//
//  ChooseTransportationViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol ChooseTransportationViewControllerDelegate: AnyObject
{
    @objc optional func onConfirmChanges(_ selected: TransportRadioButton?)
    @objc optional func onSelectionChanges(_ selected: TransportRadioButton?)
}

class ChooseTransportationViewController: UIViewController
{
    public weak var delegate: ChooseTransportationViewControllerDelegate?
    
    public var dataSource: [TransportRadioButton]? { didSet {
        guard let dataSource = dataSource
        else { return }
        radioButton = RadioButtonManager(
            dataSource,
            onSelected: { button in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn)
                {
                    button.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    button.backgroundView.backgroundColor = .systemGreen
                }
            },
            onDeselect: { button in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn)
                {
                    button.imageView.transform = CGAffineTransform.identity
                    button.backgroundView.backgroundColor = .secondarySystemBackground
                }
            }
        )
    }}
    
    private(set) var radioButton: RadioButtonManager<TransportRadioButton>?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    public init(_ dataSource: [TransportRadioButton]?)
    {
        super.init(nibName: "ChooseTransportationViewController", bundle: nil)
        self.dataSource = dataSource
        ({ self.dataSource = self.dataSource })()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        layoutScrollView()
        dataSource?.forEach { $0.addTarget(self, action: #selector(onRadioButtonSelected(_:)), for: .touchUpInside) }
    }
    
    private func layoutScrollView()
    {
        guard let dataSource = dataSource
        else { return }

        var prev: TransportRadioButton?
        for button in dataSource
        {
            // button design
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bgColor = .secondarySystemBackground
            button.backgroundView.layer.cornerRadius = 8
            button.clipsToBounds = false
            // scroll view layout
            scrollView.addSubview(button)
            // leading button is when the prev is still nil
            if let prev = prev
            {
                button.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 16.0).isActive = true
            }
            else
            {
                button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
            }
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: scrollView.topAnchor),
                button.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                button.heightAnchor.constraint(equalToConstant: 135.0),
                button.widthAnchor.constraint(equalToConstant: 120.0)
            ])
            prev = button
        }
        prev?.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.0).isActive = true
    }
    
    @objc private func onRadioButtonSelected(_ sender: TransportRadioButton)
    {
        radioButton?.selected = sender
    }

    @IBAction func onConfirmChanges(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmChanges?(radioButton?.selected)
    }
}
