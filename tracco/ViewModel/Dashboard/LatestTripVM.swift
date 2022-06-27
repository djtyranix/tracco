//
//  LatestTripVM.swift
//  tracco
//
//  Created by Michael Ricky on 27/06/22.
//

import UIKit

class LatestTripVM: NSObject {
    let repository = TripRepository.sharedInstance
        
    func isAlreadyHavingTrip() -> Bool {
        if repository.getTripCount() == 0 || repository.getTripCount() == -1 {
            return false
        } else {
            return true
        }
    }
    
    func getAllTrip() -> [TripModel] {
        return repository.getAllData()
    }
}
