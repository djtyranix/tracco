//
//  ChooseChangeTransportHelper.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 13/06/22.
//

import Foundation
import UIKit

class ChooseChangeTransportBase<T>: UIViewController
{
    private(set) var radioButton: RadioButtonManager<TransportRadioButton>?
    private let selectedBackgroundColor = UIColor(named: "MainGreen20")
    private let selectedForegroundColor = UIColor(named: "MainGreen90")
    
    init(_ dataSource: [TransportType]?)
    {
        super.init(nibName: String(describing: T.self), bundle: nil)
        radioButton = createRadioButton(dataSource)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        radioButton?.buttons.forEach { $0.addTarget(self, action: #selector(onRadioButtonSelected(_:)), for: .touchUpInside) }
    }
    
    @objc func onRadioButtonSelected(_ sender: TransportRadioButton)
    {
        radioButton?.selected = sender
    }
    
    func layoutScrollView(_ scrollView: UIScrollView)
    {
        guard let dataSource = radioButton?.buttons
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
    
    private func createRadioButton(_ dataSource: [TransportType]?) -> RadioButtonManager<TransportRadioButton>?
    {
        // make sure is not nil
        guard let dataSource = dataSource
        else { return nil }
        
        // create a button based on type
        let buttons: [TransportRadioButton] = dataSource.map {
            let vm = TransportRadioButtonVM($0)
            let button = TransportRadioButton()
            button.title = vm.name
            button.image = vm.image
            return button
        }
        
        // create a radio button manager
        return RadioButtonManager(
            buttons,
            onSelected: { button in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn)
                { [unowned self] in
                    button.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    button.backgroundView.backgroundColor = selectedBackgroundColor
                    button.titleLabel.textColor = selectedForegroundColor
                }
            },
            onDeselect: { button in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn)
                {
                    button.imageView.transform = CGAffineTransform.identity
                    button.backgroundView.backgroundColor = .secondarySystemBackground
                    button.titleLabel.textColor = .label
                }
            }
        )
    }
}
