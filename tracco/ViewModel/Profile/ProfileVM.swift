//
//  ProfileVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import Foundation

class ProfileVM
{
    // performance requirements based on total carbon reduced / total carbon emission
    enum Performance: Double, CaseIterable { case good = 2, moderate = 1, bad = 0.0 }
    
    public let mostUsedTransportText: String
    public let trackCountText: String
    public let totalCarbonEmissionText: String
    public let spendCostInIDRText: String
    public let distanceInKmText: String
    public let carbonEmissionReducedInKgText: String
    public let encouragementText: String
    public let performance: Performance
    public let treesOffsetting: UInt
    
    public init(_ model: ProfileModel)
    {
        carbonEmissionReducedInKgText = RoundingDigit(model.carbonEmissionInKgReducedTotal, kind: .number).getString(precision: 2)
        treesOffsetting = UInt(model.carbonEmissionInKgReducedTotal / OffsetEntity.tree.rawValue)
        trackCountText = String(model.tripTrackCount)
        distanceInKmText = RoundingDigit(model.distanceTotal, kind: .number).getString(precision: 2)
        spendCostInIDRText = RoundingDigit(model.costTotal, kind: .currency).getString(precision: 2)
        totalCarbonEmissionText = String(format: "%.2f", model.carbonEmissionInKgTotal)
        
        if let mostUsedTransport = model.mostUsedTransport
        {
            mostUsedTransportText = "\(mostUsedTransport)".capitalized
        }
        else
        {
            mostUsedTransportText = "None"
        }
        
        let score = model.carbonEmissionInKgReducedTotal / model.carbonEmissionInKgTotal
        let performance = ({ () -> Performance in
            for perf in Performance.allCases
                { if (score > perf.rawValue) { return perf } }
            return .bad
        })()
        
        let text: String
        switch (performance)
        {
        case .bad:
            text = "Oh No! You used cars or motorcycles too much ☹️ You should try using public transportation to reduce your carbon emission"
            break
        case .moderate:
            text = "You are on the right track to help reduce carbon emission ☺️ Please continue using public transportation 👍"
            break
        case .good:
            text = "Your performance is truly outstanding to help shaping a greener earth ❤️ Please maintain it chief 😆👍"
            break
        }
        
        self.performance = performance
        self.encouragementText = text
    }
}
