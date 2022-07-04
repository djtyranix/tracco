//
//  ActivateLocationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import UIKit

// currently only support 2 action
class AppAlertController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionContainerView: UIView!
    
    private var actions: [AppAlertAction] = []
    
    public var titleText: String? { didSet {
        titleLabel?.text = titleText
    }}
    
    public var message: String? { didSet {
        messageLabel?.text = message
    }}
    
    public var image: UIImage? { didSet {
        imageView?.image = image
    }}
    
    public init(title: String?, message: String?, image: UIImage?)
    {
        self.titleText  = title
        self.image      = image
        self.message    = message
        
        super.init(nibName: "AppAlertController", bundle: nil)
        
        self.modalPresentationStyle    = .custom
        self.transitioningDelegate     = AlertPresentationTransitioningManager.shared
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // invoke didSet property observer
        ({ self.image = self.image })()
        ({ self.message = self.message })()
        ({ self.titleText = self.titleText })()
        // default app settings
        self.view.layer.cornerRadius   = 12
        // layout
        layoutActionView()
    }
    
    private func layoutActionView()
    {
        var lastButton: UIButton?
        for (i, action) in actions.enumerated()
        {
            let button = action.button
            button.accessibilityIdentifier = String(i)
            button.isUserInteractionEnabled = true
            button.addTarget(self, action: #selector(onActionButton(_:)), for: .touchUpInside)
            
            let buttonSpacing = actionContainerView.subviews.isEmpty ? 0.0 : 16.0
            let leadingAnchor = actionContainerView.subviews.last?.trailingAnchor ??
                self.actionContainerView.leadingAnchor
            
            self.actionContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalTo: actionContainerView.heightAnchor),
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonSpacing),
            ])
            lastButton?.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            lastButton = button
        }
        lastButton?.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor).isActive = true
    }
    
    public func addAction(_ action: AppAlertAction)
    {
        actions.append(action)
    }
    
    @objc private func onActionButton(_ sender: StateBackgroundButton)
    {
        guard let identifier = sender.accessibilityIdentifier,
              let index = Int(identifier)
        else
        {
            self.dismiss(animated: true)
            return
        }
        let action = actions[index]
        action.handler?(action)
    }
}
