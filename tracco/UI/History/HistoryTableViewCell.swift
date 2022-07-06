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
    
    public static let nib = UINib.init(nibName: "HistoryTableViewCell", bundle: nil)
    public static let cellDesiredHeight: CGFloat = 72 + 16
    
    private var selectedCellColor = UIColor(named: "Color Cell Selected")
    private var identityBackgroundColor: UIColor?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // disable default gray style when clicked or long press
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        if (selected == false) { return }
        if (identityBackgroundColor == nil) { identityBackgroundColor = containerView.backgroundColor }
        UIView.animate(withDuration: 0.02, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            containerView.backgroundColor = selectedCellColor
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
                containerView.backgroundColor = identityBackgroundColor
            })
        })
    }
    
    public func setupCell(_ model: TripModel)
    {
        let tripDate                        = model.transits.first!.beginDate
        let longestTransport                = model.longestTransportUse!.type
        
        var dateText = String()
        let formatter = DateFormatter()
        
        if (Calendar.current.isDateInToday(tripDate))
        {
            formatter.dateFormat = ", d MMM yy, HH:mm"
            dateText = "Today"
        }
        else if (Calendar.current.isDateInYesterday(tripDate))
        {
            formatter.dateFormat = ", d MMM yy, HH:mm"
            dateText = "Yesterday"
        }
        else
        {
            formatter.dateFormat = "EEEE, d MMM yy, HH:mm"
        }
        
        dateText += formatter.string(from: tripDate)
        
        let descriptionText = String(
            format: "%@ to %@",
            model.transits.first?.transitPath.startTitle ?? "Unknown",
            model.transits.last?.transitPath.endTitle ?? "Unknown"
        )
        
        descriptionLabel.text               = descriptionText
        transportImageView.image            = longestTransport.image
        transportImageView.backgroundColor  = longestTransport.backgroundColor
        dateLabel.text                      = dateText
    }
}
