//
//  TransportCalloutView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 30/06/22.
//

import Foundation
import UIKit
import MapKit

@IBDesignable
class TransportCalloutView: UIView
{
    @IBOutlet weak var transportTypeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var carbonEmissionLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    public var type: TransportType? { didSet {
        guard let type = type
        else
        {
            transportTypeLabel.text = "Unknown Type"
            return
        }
        transportTypeLabel.text = "\(type)".capitalized
    }}
    
    @IBInspectable var durationText: String! { didSet {
        durationLabel.text = durationText
    }}
    
    @IBInspectable var distanceInKm: Double = 0.0 { didSet {
        distanceLabel.text = String(format: "%.2f km", distanceInKm)
    }}
    
    @IBInspectable var carbonInKg: Double = 0.0 { didSet {
        carbonEmissionLabel.text = RoundingDigit(carbonInKg, kind: .number).getString(precision: 2) + " kg CO2"
    }}
    
    @IBInspectable var costInIDR: Double = 0.0 { didSet {
        costLabel.text = RoundingDigit(costInIDR, kind: .currency).getString(precision: 2) + " IDR"
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
    
    public func setDurationLabel(beginDate: Date, endDate: Date)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        durationLabel.text = formatter.string(from: beginDate) + " - " + formatter.string(from: endDate)
    }
}
