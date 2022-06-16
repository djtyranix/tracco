//
//  TripDetailView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 15/06/22.
//

import Foundation
import UIKit
import MapKit

@IBDesignable
class TripDetailView: UIView
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    public let failGetLocationDefaultName = "[Cannot Specify Location]"
    public let pinProgressImage = UIImage(named: "PinLine")
    
    private(set) var contents: [TripDetailContentView]?
    
    public var model: [TransitModel]? { didSet {
        guard let model = model, model.isEmpty == false
        else { return }
        // remove previous subviews
        contents = []
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        // create new subview
        var prev: TripDetailContentView!
        model.forEach
        {
            let contentView             = TripDetailContentView()
            contentView.title           = "[No Location]"
            contentView.costInIDR       = $0.costInIDR
            contentView.carbonInKg      = $0.carbonEmissionInKg
            contentView.transportImage  = $0.transitPath.type.image
            contentView.time            = $0.transitPath.beginDate
            contentView.isArrived       = false
            // obtain location non-concurrently
            if let startingCoord = $0.transitPath.coords.first
            {
                obtainLocationName(contentView, coordinate: startingCoord, completion: { [weak self] in
                    contentView.title = $0 ?? self?.failGetLocationDefaultName
                })
            }
            // add subview before adding constraint
            contents?.append(contentView)
            scrollView.addSubview(contentView)
            // add constraint to support auto layout scroll view
            let boundTopAnchor = prev == nil ? scrollView.topAnchor : prev!.bottomAnchor
            let boundTopConstant = prev == nil ? 0.0 : 12.0
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: boundTopAnchor, constant: boundTopConstant),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.heightAnchor.constraint(equalToConstant: 40)
            ])
            // update for next view
            prev = contentView
        }
        // trip end content view
        let endContentView = TripDetailContentView()
        endContentView.isArrived = true
        endContentView.time = model.last?.transitPath.endDate
        endContentView.title = "[No Location]"
        // obtain location non-concurrently
        if let endingCoord = model.last?.transitPath.coords.last
        {
            obtainLocationName(endContentView, coordinate: endingCoord, completion: { [weak self] in
                endContentView.title = $0 ?? self?.failGetLocationDefaultName
            })
        }
        contents?.append(endContentView)
        scrollView.addSubview(endContentView)
        endContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endContentView.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 12),
            endContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            endContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            endContentView.heightAnchor.constraint(equalToConstant: 40)
        ])
        endContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 24).isActive = true
        layoutPinLine(contents: contents)
        // update distance and time elapsed
        let totalDistanceInKm = model.reduce(0.0, { return $0 + $1.transitPath.distanceInKm })
        var totalTimeInSeconds: TimeInterval = 0
        if let firstDate = model.first?.transitPath.beginDate,
           let endDate = model.last?.transitPath.endDate
        {
            totalTimeInSeconds = endDate.timeIntervalSince(firstDate)
        }
        let hours = UInt(totalTimeInSeconds / (60 * 60))
        let minutes = UInt(totalTimeInSeconds / 60)
        durationLabel.text = hours == 0 ?
            String(format: "%d minutes", minutes) :
            String(format: "%d hours %d minutes", hours, minutes)
        distanceLabel.text =
            String(format: "%.1f km", totalDistanceInKm)
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
    
    private func layoutPinLine(contents: [TripDetailContentView]?)
    {
        guard let contents = contents, contents.count >= 2
        else { return }

        for i in 0..<contents.count - 1
        {
            let topView = contents[i]
            let botView = contents[i + 1]
            
            let imageView = UIImageView(image: pinProgressImage)
            scrollView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: topView.pinImageView.bottomAnchor, constant: 6).isActive = true
            imageView.centerXAnchor.constraint(equalTo: botView.pinImageView.centerXAnchor).isActive = true
        }
    }
    
    private func obtainLocationName(_ contentView: TripDetailContentView, coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void)
    {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if (error != nil) { return }
            completion(placemarks?.first?.name)
        }
    }
}
