//
//  TripDetailContentView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 15/06/22.
//

import Foundation
import UIKit

@IBDesignable
class TripDetailContentView: UIView
{
    @IBOutlet weak var transportImageView: UIImageView!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var carbonLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    @IBInspectable var transportImage: UIImage! { didSet {
        transportImageView.image = transportImage
    }}
    
    @IBInspectable var isArrived: Bool = false { didSet {
        pinImageView.image = UIImage(named: isArrived ? "EndPin" : "LocPin")
        detailView.isHidden = isArrived
        transportImageView.isHidden = isArrived
    }}
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var time: Date! { didSet {
        timeLabel.text = timeFormatter.string(from: time)
    }}
    
    @IBInspectable var carbonInKg: Double = 0.0 { didSet {
        carbonLabel.text = RoundingDigit(carbonInKg, kind: .number).getString(precision: 1) + " kg CO2"
    }}
    
    @IBInspectable var costInIDR: Double = 0.0 { didSet {
        costLabel.text = RoundingDigit(costInIDR, kind: .currency).getString(precision: 1) + " IDR"
    }}
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
    
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
