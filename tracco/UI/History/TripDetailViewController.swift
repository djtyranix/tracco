//
//  TripDetailViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 19/06/22.
//

import Foundation
import UIKit
import MapKit

class TripDetailViewController: UIViewController
{
    struct GeocodingState
    {
        enum Status { case initiated, completed, error }
        
        var geocoder: CLGeocoder
        var location: CLLocation
        var status: Status
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    public var viewModel: SummaryVM?
    public var isScrollEnable: Bool = false
    
    private var contents: [TripDetailContentView] = []
    private var geocoders: [GeocodingState] = []
    private var timerGeocoding: Timer?

    public let unknownLocationName      = "Unknown Location"
    public let pendingGetLocationName   = "Getting Location Info..."
    public let pinProgressImage         = UIImage(named: "PinLine")
    
    private let alertCannotUpdateLocation: UIAlertController = {
        let alert = UIAlertController(
            title: "Failed Getting Location Info",
            message: "Make sure you connected to the internet service in order to get location information",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "I Understand", style: .default))
        return alert
    }()
    
    private var alertCannotUpdateLocationFirstTimeDisplayed: Bool = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        layoutContentView()
        layoutPinLine()
        scrollView.isScrollEnabled = isScrollEnable
    }
    
    // no internet connection for a long time can cause geocoding to stop
    @objc func geocoding()
    {
        if geocoders.allSatisfy({ $0.status == .completed })
        {
            timerGeocoding?.invalidate()
            return
        }
            
        for (i, status) in geocoders.enumerated()
        {
            if status.status != .completed && status.geocoder.isGeocoding == false
            {
                // obtain location name
                let status = geocoders[i]
                status.geocoder.reverseGeocodeLocation(status.location) { [weak self] placemarks, error in
                    if (error != nil)
                    {
                        self?.geocoders[i].status = .error
                        if let vc = self, vc.alertCannotUpdateLocationFirstTimeDisplayed
                        {
                            vc.present(vc.alertCannotUpdateLocation, animated: true)
                            vc.alertCannotUpdateLocationFirstTimeDisplayed = false
                        }
                        return
                    }
                    self?.geocoders[i].status = .completed
                    let locationName = placemarks?.first?.name ?? self?.unknownLocationName
                    self?.viewModel?.tripDetailContents[i].locationName = locationName
                    DispatchQueue.main.async { self?.contents[i].title = locationName }
                }
            }
        }
    }
    
    private func layoutContentView()
    {
        // make sure there are data to be shown
        guard let viewModel = viewModel
        else { return }
        // update label
        durationLabel.text = viewModel.tripDurationText
        distanceLabel.text = viewModel.tripDistanceText
        // remove previous subviews
        contents = []
        geocoders = []
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        // create new subview
        let lastIndex = viewModel.tripDetailContents.endIndex - 1
        var prev: TripDetailContentView?
        for (i, content) in viewModel.tripDetailContents.enumerated()
        {
            let contentView             = TripDetailContentView()
            contentView.title           = content.locationName ?? pendingGetLocationName
            contentView.costInIDR       = content.costInIDR
            contentView.carbonInKg      = content.carbonEmissionInKg
            contentView.transportImage  = content.transportType.image
            contentView.time            = content.date
            contentView.isArrived       = i == lastIndex
            // add subview before adding constraint
            contents.append(contentView)
            scrollView.addSubview(contentView)
            // schedule update pending location name
            geocoders.append(GeocodingState(
                geocoder: CLGeocoder(),
                location: CLLocation(latitude: content.coord.latitude, longitude: content.coord.longitude),
                status: .initiated
            ))
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
        prev?.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24).isActive = true
        // background job to get location name if not yet obtained
        timerGeocoding = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(geocoding), userInfo: nil, repeats: true)
    }
    
    private func layoutPinLine()
    {
        if contents.count < 2 { return }

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
}
