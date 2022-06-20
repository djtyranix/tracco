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
    
    // this will contain all information of each transit (tranport change)
    // including the arrival destination information
    // example:
    // models   = car -> bus -> train
    // result   = car(begin date) -> bus(begin date) -> train(begin date) -> train(end date)
    public var tripDetailContents: [TripDetailContent]
    public let tripDistanceText: String
    public let tripDurationText: String
    
    public let otherCarbonEmissionInKgText: String = "0.0"
    public let otherCostInIDRText: String = "0.0"
    public let otherTitleText: String = "Public Transport"
    
    public let currentCarbonEmissionInKgText: String
    public let currentCostInIDRText: String
    
    public init(_ models: [TransitModel])
    {
        let currentCostInIDR            = models.reduce(0.0, { return $0 + $1.costInIDR })
        let currentCarbonEmissionInKg   = models.reduce(0.0, { return $0 + $1.carbonEmissionInKg })
        
        currentCostInIDRText = RoundingDigit(currentCostInIDR, kind: .currency).getString(precision: 1)
        currentCarbonEmissionInKgText = RoundingDigit(currentCarbonEmissionInKg, kind: .number).getString(precision: 1)
        // trip distance
        let tripDistance = models.reduce(0.0, { return $0 + $1.transitPath.distanceInKm })
        tripDistanceText = String(format: "%.1f km", tripDistance)
        // trip duration
        let tripDuration: TimeInterval
        if let departureDate = models.first?.transitPath.beginDate,
           let arrivalDate = models.last?.transitPath.endDate
        {
            tripDuration = arrivalDate.timeIntervalSince(departureDate)
        }
        else
        {
            tripDuration = 0.0
        }
        let hours   = UInt(tripDuration / (60 * 60))
        let minutes = UInt(tripDuration / 60)
        tripDurationText = hours == 0 ?
            String(format: "%d minutes", minutes) :
            String(format: "%d hours %d minutes", hours, minutes)
        // trip detail contents
        var contents = models.map({
            return TripDetailContent(
                carbonEmissionInKg: $0.carbonEmissionInKg,
                costInIDR: $0.costInIDR,
                transportType: $0.transitPath.type,
                date: $0.transitPath.beginDate,
                coord: $0.transitPath.coords.first!
            )
        })
        if let lastModel = models.last
        {
            let destinationTrip = TripDetailContent(
                carbonEmissionInKg: 0,
                costInIDR: 0,
                transportType:lastModel.transitPath.type,
                date: lastModel.transitPath.endDate,
                coord: lastModel.transitPath.coords.last!
            )
            contents.append(destinationTrip)
        }
        tripDetailContents = contents
    }
}
