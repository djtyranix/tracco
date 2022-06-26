//
//  DashboardViewModel.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

class DashboardVM
{
    public let carbonEmissionValueText: String
    public let mostUsedTransportText: String
    public let encouragementText: String?
    
    public init(_ model: ProfileModel)
    {
        if let mostUsedTransport = model.mostUsedTransport
        {
            mostUsedTransportText = "\(mostUsedTransport)".capitalized
        }
        else
        {
            mostUsedTransportText = "None"
        }
        
        carbonEmissionValueText = String(format: "%.2f", model.carbonEmissionInKgTotal)
        
        let offsetTrees = model.offsetTrees
        encouragementText = offsetTrees <= 0 ? nil : String(
            format: "Yay 😆 You have reduced carbon emissions " +
            "which is equal to offsetting with %d Trees / Year 🌲👊",
            offsetTrees
        )
    }
}
