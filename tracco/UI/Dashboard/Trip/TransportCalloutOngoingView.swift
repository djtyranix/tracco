//
//  TransportCalloutOngoingView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 30/06/22.
//

import Foundation
import UIKit

@IBDesignable
class TransportCalloutOngoingView: UIView
{
    @IBOutlet weak var transportTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var type: TransportType? { didSet {
        guard let type = type
        else
        {
            transportTypeLabel.text = "Unknown Type"
            return
        }
        transportTypeLabel.text = "\(type)".capitalized
    }}
    
    public var date: Date? { didSet {
        guard let date = date
        else
        {
            dateLabel.text = "Unknown Time"
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        dateLabel.text = formatter.string(from: date)
    }}
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadNib(self)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        loadNib(self)
    }
}
