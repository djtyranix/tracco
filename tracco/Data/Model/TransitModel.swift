//
//  TransitModel.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 16/06/22.
//

import Foundation

struct TransitModel : Codable
{
    // Transit location information
    var transitPath: TransitPath
    // carbon emission in kg
    var carbonEmissionInKg: Double
    // cost of transportation in IDR
    var costInIDR: Double
    // transportation used in the transit
    var type: TransportType
    // the distance of the path traversed
    var distanceInKm: Double
    // the time when the transit begins
    var beginDate: Date
    // the time when the transit ends
    var endDate: Date
    // how long the transit has been going
    var duration: TimeInterval {
        get { return endDate.timeIntervalSince(beginDate) }
        set { endDate = Date(timeInterval: newValue, since: beginDate) }
    }
}
