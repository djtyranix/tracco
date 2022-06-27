//
//  TripModel.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 27/06/22.
//

import Foundation

struct TripModel: Codable
{
    var id: Int
    var transits: [TransitModel]
    
    subscript(index: Int) -> TransitModel
    {
        get { return transits[index] }
        mutating set { transits[index] = newValue }
    }
    
    var shortestTransportUse: TransitModel? { get {
        return self.transits.min(by: { return $0.distanceInKm < $1.distanceInKm })
    }}
    
    var longestTransportUse: TransitModel? { get {
        return self.transits.max(by: { return $0.distanceInKm < $1.distanceInKm })
    }}
}
