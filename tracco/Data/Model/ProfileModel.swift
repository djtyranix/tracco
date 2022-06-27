//
//  ProfileModel.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation

struct ProfileModel : Codable
{
    var distanceInCar: Double
    var distanceInMotor: Double
    var distanceInBus: Double
    var distanceInTrain: Double
    
    var costInCar: Double
    var costInMotor: Double
    var costInBus: Double
    var costInTrain: Double
    
    var tripTrackCount: UInt
    var carbonEmissionInKgTotal: Double
    var carbonEmissionInKgReducedTotal: Double
    
    var distanceTotal: Double { get {
        distanceInCar + distanceInMotor + distanceInBus + distanceInTrain
    }}
    
    var costTotal: Double { get {
        costInCar + costInMotor + costInBus + costInTrain
    }}
    
    var mostUsedTransport: TransportType? { get {
        let max = [distanceInCar, distanceInMotor, distanceInBus, distanceInTrain].max()
        if (max == distanceInCar)   { return .car }
        if (max == distanceInMotor) { return .motor }
        if (max == distanceInBus)   { return .bus }
        if (max == distanceInTrain) { return .train }
        return nil
    }}
    
    var offsetTrees: Int { get {
        return Int(carbonEmissionInKgReducedTotal / OffsetEntity.tree.rawValue)
    }}
    
    init()
    {
        self.distanceInBus = 0
        self.distanceInCar = 0
        self.distanceInMotor = 0
        self.distanceInTrain = 0
        
        self.costInBus = 0
        self.costInCar = 0
        self.costInMotor = 0
        self.costInTrain = 0
        
        self.tripTrackCount = 0
        self.carbonEmissionInKgTotal = 0
        self.carbonEmissionInKgReducedTotal = 0
    }
    
    mutating func add(_ model: TripModel)
    {
        self.tripTrackCount += 1
        
        for transit in model.transits
        {
            let carbonInCar = TransportType.car.rawValue.carbon * transit.distanceInKm
            let carbonReduced = carbonInCar - transit.carbonEmissionInKg
            
            self.carbonEmissionInKgTotal += transit.carbonEmissionInKg
            self.carbonEmissionInKgReducedTotal += carbonReduced
            
            switch transit.type
            {
            case .car:
                self.distanceInCar += transit.distanceInKm
                self.costInCar += transit.costInIDR
                break
            case .bus:
                self.distanceInBus += transit.distanceInKm
                self.costInBus += transit.costInIDR
                break
            case .motor:
                self.distanceInMotor += transit.distanceInKm
                self.costInMotor += transit.costInIDR
            case .train:
                self.distanceInTrain += transit.distanceInKm
                self.costInTrain += transit.costInIDR
                break
            }
        }
    }
}
