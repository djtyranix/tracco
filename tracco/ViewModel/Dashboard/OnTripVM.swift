//
//  OnTripVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import Foundation
import MapKit
import UIKit

class OnTripVM
{
    private let repository = TripRepository.sharedInstance
    
    public var transportType: TransportType { didSet {
        transportEmission = transportType.rawValue.convertibleObject
        transportEmission.distanceUnits = .kilo
        transportEmission.massUnits = .kilo
    }}
    
    public var currLocation: CLLocation? { didSet {
        
        guard let currLocation = currLocation
        else { return }
        
        if let prevLocaton = prevValidLocation
        {
            let meters = currLocation.distance(from: prevLocaton)
            distanceInKm += meters * SystemUnits.kilo.rawValue
        }
        
        prevValidLocation = oldValue
    }}
    
    private(set) var prevValidLocation: CLLocation?
    
    private(set) var distanceInKm: Double { didSet {
        distanceInKmText = String(format: "%.2f km", distanceInKm)
        carbonEmissionInKg = distanceInKm * transportEmission.carbon
        totalCostInIDR = transportType.cost(distanceInKm)
    }}
    
    @Published
    private(set) var distanceInKmText: String!
    
    private(set) var totalCostInIDR: Double! { didSet {
        totalCostInIDRText = String(format: "IDR %.2f", totalCostInIDR)
    }}
    
    @Published
    private(set) var totalCostInIDRText: String!
    
    private(set) var carbonEmissionInKg: Double! { didSet {
        carbonEmissionInKgText = String(format: " %.2f kg CO2", carbonEmissionInKg)
    }}
    
    @Published
    private(set) var carbonEmissionInKgText: String!
    
    private var transportEmission: CO2E!
    
    public init(_ type: TransportType, currentLocation: CLLocation?)
    {
        self.transportType      = type
        self.currLocation       = currentLocation
        self.distanceInKm       = 0
        ({ self.transportType   = self.transportType })()
        ({ self.distanceInKm    = self.distanceInKm })()
    }
    
    func saveTripData(tripData: TripModel) -> Bool
    {
        return repository.saveData(trip: tripData)
    }
}
