//
//  ProfileModel.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation

struct ProfileModel: Codable
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
        
        let carbonInCar = TransportType.car.rawValue.carbon * model.transitPath.distanceInKm
        let carbonReduced = carbonInCar - model.carbonEmissionInKg
        self.carbonEmissionInKgReducedTotal += carbonReduced
        
        switch model.transitPath.type
        {
        case .car:
            self.distanceInCar += model.transitPath.distanceInKm
            self.costInCar += model.costInIDR
            break
        case .bus:
            self.distanceInBus += model.transitPath.distanceInKm
            self.costInBus += model.costInIDR
            break
        case .motor:
            self.distanceInMotor += model.transitPath.distanceInKm
            self.costInMotor += model.costInIDR
        case .train:
            self.distanceInTrain += model.transitPath.distanceInKm
            self.costInTrain += model.costInIDR
            break
        }
    }
}
