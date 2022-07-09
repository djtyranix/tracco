//
//  SummaryVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 18/06/22.
//

import Foundation
import UIKit
import MapKit

class SummaryVM
{
    // contain information of each transit happened in the user trip
    struct TripDetailContent
    {
        var locationName: String?
        var carbonEmissionInKg: Double
        var costInIDR: Double
        var transportType: TransportType
        var date: Date
        var coord: CLLocationCoordinate2D
    }
    
    // for updating geolocation in summary vc
    public var model: TripModel
    
    public var title: String = "Trip Summary"
    
    // this will contain all information of each transit (tranport change)
    // including the arrival destination information
    // example:
    // models   = car -> bus -> train
    // result   = car(begin date) -> bus(begin date) -> train(begin date) -> train(end date)
    public var tripDetailContents: [TripDetailContent]
    public let tripDistanceText: String
    public let tripDurationText: String
    
    public let otherCarbonEmissionInKgText: String
    public let otherCostInIDRText: String
    public let otherTitleText: String
    
    public let otherCardBackgroundColor: UIColor?
    public let otherCardForegroundColor: UIColor?
    
    public let comparisonEncouragementText: String
    
    public let currentCarbonEmissionInKgText: String
    public let currentCostInIDRText: String
    
    public init(_ model: TripModel)
    {
        self.model = model
        
        let currentCostInIDR            = model.transits.reduce(0.0, { return $0 + $1.costInIDR })
        let currentCarbonEmissionInKg   = model.transits.reduce(0.0, { return $0 + $1.carbonEmissionInKg })
        
        currentCostInIDRText = RoundingDigit(currentCostInIDR, kind: .currency).getString(precision: 2)
        currentCarbonEmissionInKgText = String(format: "%.2f", currentCarbonEmissionInKg)
        // trip distance
        let tripDistance = model.transits.reduce(0.0, { return $0 + $1.distanceInKm })
        tripDistanceText = String(format: "%.2f km", tripDistance)
        // trip duration
        let tripDuration: TimeInterval
        if let departureDate = model.transits.first?.beginDate,
           let arrivalDate = model.transits.last?.endDate
        {
            tripDuration = arrivalDate.timeIntervalSince(departureDate)
        }
        else
        {
            tripDuration = 0.0
        }
        tripDurationText = tripDuration.string
        // trip detail contents
        var contents = model.transits.map({
            return TripDetailContent(
                locationName: $0.transitPath.startTitle,
                carbonEmissionInKg: $0.carbonEmissionInKg,
                costInIDR: $0.costInIDR,
                transportType: $0.type,
                date: $0.beginDate,
                coord: CLLocationCoordinate2D(
                    latitude: $0.transitPath.startLatitude,
                    longitude: $0.transitPath.startLongitude
                )
            )
        })
        if let lastModel = model.transits.last
        {
            let destinationTrip = TripDetailContent(
                locationName: lastModel.transitPath.endTitle,
                carbonEmissionInKg: 0,
                costInIDR: 0,
                transportType:lastModel.type,
                date: lastModel.endDate,
                coord: CLLocationCoordinate2D(
                    latitude: lastModel.transitPath.endLatitude,
                    longitude: lastModel.transitPath.endLongitude
                )
            )
            contents.append(destinationTrip)
        }
        tripDetailContents = contents
        
        // comparison with other transport
        let busCarbonEmission = tripDistance * TransportType.bus.rawValue.carbon
        let carCarbonEmission = tripDistance * TransportType.car.rawValue.carbon
        
        // if carbon emission is 120% bus carbon, then its okay
        let goodMaxCarbonEmission = 1.2 * busCarbonEmission
        let isTripFriendlyCarbonEmission = currentCarbonEmissionInKg <= goodMaxCarbonEmission
        
        // if good carbon emission, compare it with car (bad) transport
        if (isTripFriendlyCarbonEmission)
        {
            let carEstimatedCost = TransportType.car.cost(tripDistance)
            otherCarbonEmissionInKgText = String(format: "%.2f", carCarbonEmission)
            otherCostInIDRText = RoundingDigit(carEstimatedCost, kind: .currency).getString(precision: 2)
            otherTitleText = "Private Car"
            
            otherCardBackgroundColor = UIColor(named: "CardBadBackground")
            otherCardForegroundColor = UIColor(named: "CardBadForeground")
            
            comparisonEncouragementText = "Here’s your total carbon emission and cost for this trip. You have saved & reduced carbon emissions nicely 👍 Good job! View the comparison below if you use private transportation."
        }
        // if bad carbon emission, compare it with bus (good) transport
        else
        {
            let busEstimatedCost = TransportType.bus.cost(tripDistance)
            otherCarbonEmissionInKgText = String(format: "%.2f", busCarbonEmission)
            otherCostInIDRText = RoundingDigit(busEstimatedCost, kind: .currency).getString(precision: 2)
            otherTitleText = "Using Bus"
            
            otherCardBackgroundColor = UIColor(named: "CardGoodBackground")
            otherCardForegroundColor = UIColor(named: "CardGoodForeground")
            
            comparisonEncouragementText = "Here’s your total carbon emission and cost for this trip. you can save more cost 🤑 and reduce carbon emission by using public transportation 😎, view the comparison below."
        }
    }
}
