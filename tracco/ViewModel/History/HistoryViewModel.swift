//
//  HistoryViewModel.swift
//  tracco
//
//  Created by Michael Ricky on 27/06/22.
//

import UIKit

class HistoryViewModel: NSObject {
    let repository = TripRepository.sharedInstance
    
    func getTripCount() -> Int {
        return repository.getTripCount()
    }
    
    func getAllTrip() -> [TripModel] {
        return repository.getAllData()
    }
}
