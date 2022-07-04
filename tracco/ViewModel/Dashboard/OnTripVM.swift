//
//  OnTripVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import Foundation
import MapKit
import UIKit

// TODO: adjust map strokes and locations upto sampleSize
// TODO: right now, we are only able to update nextLocation
class OnTripVM
{
    public let processor = ULProcessor(sampleSize: 2, minDistanceMovement: 50)
    
    private let repository = TripRepository.sharedInstance
    
    public var transportType: TransportType { didSet {
        transportEmission = transportType.rawValue.convertibleObject
        transportEmission.distanceUnits = .kilo
        transportEmission.massUnits = .kilo
    }}
    
    public var currValidLocation: CLLocation { get {
        let currIndex = processor.sample.count - 1
        return processor.sample[currIndex]
    }}
    
    public var prevValidLocation: CLLocation? { get {
        let prevIndex = processor.sample.count - 2
        return processor.sample.count >= 2 ? processor.sample[prevIndex] : nil
    }}
    
    private(set) var distanceInKmText: String!
    private(set) var totalCostInIDRText: String!
    private(set) var carbonEmissionInKgText: String!
    
    private(set) var distanceInKm: Double { didSet {
        distanceInKmText = String(format: "%.2f km", distanceInKm)
        carbonEmissionInKg = distanceInKm * transportEmission.carbon
        totalCostInIDR = transportType.cost(distanceInKm)
    }}
    
    private(set) var totalCostInIDR: Double! { didSet {
        totalCostInIDRText = String(format: "IDR %.2f", totalCostInIDR)
    }}
    
    private(set) var carbonEmissionInKg: Double! { didSet {
        carbonEmissionInKgText = String(format: " %.2f kg CO2", carbonEmissionInKg)
    }}
    
    private var transportEmission: CO2E!
    
    public init(_ type: TransportType, currentLocation: CLLocation)
    {
        self.transportType      = type
        self.distanceInKm       = 0
        processor.update(currentLocation)
        processor.delegate = self
        ({ self.transportType   = self.transportType })()
        ({ self.distanceInKm    = self.distanceInKm })()
    }
    
    func saveTripData(tripData: TripModel) -> Bool
    {
        return repository.saveData(trip: tripData)
    }
}

extension OnTripVM: ULProcessorDelegate
{
    func location(_ processor: ULProcessor, didRefactor index: Int)
    {
        
    }
    
    func location(_ processor: ULProcessor, didAdd location: CLLocation)
    {
        if let prevLocaton = prevValidLocation
        {
            let meters = currValidLocation.distance(from: prevLocaton)
            distanceInKm += meters * SystemUnits.kilo.rawValue
        }
    }
}
