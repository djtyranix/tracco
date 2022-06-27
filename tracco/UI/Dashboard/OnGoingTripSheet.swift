//
//  OnGoingTripSheet.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 27/06/22.
//

import Foundation
import UIKit

@IBDesignable
class OnGoingTripSheet: UIControl
{
    @IBOutlet weak var transportImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var imageLabels: [UIImageView]!
    
    @IBInspectable var distance: Double = 0 { didSet {
        let format = distance >= 10 ? "%.0f km" : "%.1f km"
        distanceLabel.text = String(format: format, distance)
    }}
    
    @IBInspectable var durationInSeconds: Double = 0 { didSet {
        let hours   = Int(durationInSeconds / (60 * 60))
        let minutes = Int(durationInSeconds / 60)
        durationLabel.text = hours == 0 ?
            String(format: "%d minutes", minutes) :
            String(format: "%d hours %d minutes", hours, minutes)
    }}
    
    @IBInspectable var image: UIImage! { didSet {
        transportImageView.image = image
    }}
    
    @IBInspectable var labelColor: UIColor! { didSet {
        labels.forEach { $0.textColor = labelColor }
        imageLabels.forEach { $0.tintColor = labelColor }
    }}
    
    var type: TransportType! { didSet {
        if (type == oldValue) { return }
        image = type.image
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
