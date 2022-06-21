//
//  HistoryTableViewCell.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 20/06/22.
//

import UIKit

class HistoryTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var transportImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var identityBackgroundColor: UIColor?
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        // disable default gray style when clicked or long press
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        if (selected == false) { return }
        if (identityBackgroundColor == nil) { identityBackgroundColor = containerView.backgroundColor }
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            containerView.backgroundColor = .green
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
                containerView.backgroundColor = identityBackgroundColor
            })
        })
    }
}
