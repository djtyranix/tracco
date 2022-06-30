//
//  TransportAnnotation.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import MapKit

class TransportAnnotation: NSObject, MKAnnotation
{
    // MARK: MKAnnotation Protocol
    var coordinate: CLLocationCoordinate2D
    var title: String? = nil
    var subtitle: String? = nil
    
    // MARK: Custom Property
    var indexInModel: Int
    var type: TransportType
    var beginDate: Date
    var endDate: Date
    var carbonEmissionInKg: Double
    var distanceInKm: Double
    var costInIDR: Double
    var isOngoing: Bool
    
    private init(coordinate: CLLocationCoordinate2D, indexInModel: Int, type: TransportType, beginDate: Date, endDate: Date, carbonEmissionInKg: Double, distanceInKm: Double, costInIDR: Double, isOngoing: Bool)
    {
        self.coordinate = coordinate
        self.indexInModel = indexInModel
        self.type = type
        self.beginDate = beginDate
        self.endDate = beginDate
        self.carbonEmissionInKg = carbonEmissionInKg
        self.distanceInKm = distanceInKm
        self.costInIDR = costInIDR
        self.isOngoing = isOngoing
    }
    
    static func initOngoing(coordinate: CLLocationCoordinate2D, indexInModel: Int, type: TransportType, beginDate: Date) -> TransportAnnotation
    {
        return .init(coordinate: coordinate, indexInModel: indexInModel, type: type, beginDate: beginDate, endDate: beginDate, carbonEmissionInKg: 0, distanceInKm: 0, costInIDR: 0, isOngoing: true)
    }
    
    static func initDone(coordinate: CLLocationCoordinate2D, indexInModel: Int, type: TransportType, beginDate: Date, endDate: Date, carbonEmissionInKg: Double, distanceInKm: Double, costInIDR: Double) -> TransportAnnotation
    {
        return .init(coordinate: coordinate, indexInModel: indexInModel, type: type, beginDate: beginDate, endDate: endDate, carbonEmissionInKg: carbonEmissionInKg, distanceInKm: distanceInKm, costInIDR: costInIDR, isOngoing: false)
    }
}
