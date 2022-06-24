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
    
    mutating func add(_ model: TransitModel)
    {
        self.tripTrackCount += 1
        self.carbonEmissionInKgTotal += model.carbonEmissionInKg
        self.carbonEmissionInKgReducedTotal += 0
        
        switch model.type
        {
        case .car:
            self.distanceInCar += model.distanceInKm
            self.costInCar += model.costInIDR
            break
        case .bus:
            self.distanceInBus += model.distanceInKm
            self.costInBus += model.costInIDR
            break
        case .motor:
            self.distanceInMotor += model.distanceInKm
            self.costInMotor += model.costInIDR
        case .train:
            self.distanceInTrain += model.distanceInKm
            self.costInTrain += model.costInIDR
            break
        }
    }
}
