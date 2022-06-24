//
//  TransitData.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 09/06/22.
//

import Foundation
import MapKit

struct TransitPath: Codable
{
    // transportation used in the transit
    var type: TransportType
    // the path traversed during the transit
    var coords: [LocationCoordinate2D]
    // the distance of the path traversed
    var distanceInKm: Double
    // how much the path traversed updated per seconds, measured in Hz
    var sampleRate: Double
    // the time when the transit begins
    var beginDate: Date
    // the time when the transit ends
    var endDate: Date
    // how long the transit has been going
    var duration: TimeInterval {
        get { return endDate.timeIntervalSince(beginDate) }
        set { endDate = Date(timeInterval: newValue, since: beginDate) }
    }
    // how long the interval to update the path traversed
    var sampleInterval: Double {
        get { return 1 / sampleRate }
        set { sampleRate = 1 / newValue }
    }
}
