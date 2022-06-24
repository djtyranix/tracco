//
//  ProfileVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import Foundation

class ProfileVM
{
    public let mostUsedTransportText: String
    public let trackCountText: String
    public let totalCarbonEmissionText: String
    public let spendCostInIDRText: String
    public let distanceInKmText: String
    
    public init(_ model: ProfileModel)
    {
        trackCountText = RoundingDigit(Double(model.tripTrackCount), kind: .number).getString(precision: 2)
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
    }
}
