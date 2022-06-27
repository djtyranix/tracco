//
//  TripRepository.swift
//  tracco
//
//  Created by Michael Ricky on 24/06/22.
//

import UIKit
import CoreData

class TripRepository : NSObject {
    struct Static {
        static var instance: TripRepository?
    }
    
    class var sharedInstance: TripRepository {
        if Static.instance == nil {
            Static.instance = TripRepository()
        }
        
        return Static.instance!
    }
    
    func disposeSingleton() {
        TripRepository.Static.instance = nil
        print("FinenanceRepository Disposed")
    }
    
    private func getManagedContext() -> NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.automaticallyMergesChangesFromParent = true
        
        return managedContext
    }
    
    func saveData(trip: TripModel) -> Bool {
        let currentSummaryId = getLatestSummaryId() + 1
        
        let managedContext = self.getManagedContext()
        let entity = NSEntityDescription.entity(forEntityName: "TripEntity", in: managedContext)!
        
        for transit in trip {
            let currentTripId = getLatestTripId() + 1
            let tripEntity = NSManagedObject(entity: entity, insertInto: managedContext)
            tripEntity.setValue(currentTripId, forKey: "trip_id")
            tripEntity.setValue(currentSummaryId, forKey: "trip_summary_id")
            tripEntity.setValue(transit.transitPath.startLatitude, forKey: "trip_lat_start")
            tripEntity.setValue(transit.transitPath.startLongitude, forKey: "trip_long_start")
            tripEntity.setValue(transit.transitPath.endLatitude, forKey: "trip_lat_end")
            tripEntity.setValue(transit.transitPath.endLongitude, forKey: "trip_long_end")
            tripEntity.setValue(getTransportType(type: transit.type), forKey: "trip_transport_type")
            tripEntity.setValue(transit.costInIDR, forKey: "trip_cost")
            tripEntity.setValue(transit.carbonEmissionInKg, forKey: "trip_carbon_emission")
            tripEntity.setValue(transit.distanceInKm, forKey: "trip_distance")
            tripEntity.setValue(transit.duration, forKey: "trip_duration")
            tripEntity.setValue(transit.beginDate, forKey: "trip_date_start")
            tripEntity.setValue(transit.endDate, forKey: "trip_date_end")
            tripEntity.setValue(transit.transitPath.startTitle, forKey: "trip_name_start")
            tripEntity.setValue(transit.transitPath.endTitle, forKey: "trip_name_end")
            
            do {
                try managedContext.save()
                print("Data \(currentTripId) saved")
            } catch let error as NSError {
                print("Could not save data \(currentTripId). \(error), \(error.userInfo)")
                return false
            }
        }
        
        return true
    }
    
    func getLatestSummaryId() -> Int {
        var transitFetchArray = [NSManagedObject]()
        
        let managedContext = self.getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trip_summary_id", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            transitFetchArray = try managedContext.fetch(fetchRequest)
            let transitFetch = transitFetchArray.first
            let id: Int
            if transitFetch != nil {
                id = transitFetch?.value(forKey: "trip_summary_id") as? Int ?? 0
            } else {
                id = 0
            }
            
            return id
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return -1
        }
    }
    
    func getLatestTripId() -> Int {
        var transitFetchArray = [NSManagedObject]()
        
        let managedContext = self.getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trip_id", ascending: false)]
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            transitFetchArray = try managedContext.fetch(fetchRequest)
            let transitFetch = transitFetchArray.first
            
            let id: Int
            if transitFetch != nil {
                id = transitFetch?.value(forKey: "trip_id") as? Int ?? 0
            } else {
                id = 0
            }
            
            return id
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return -1
        }
    }
    
    func getTripCount() -> Int {
        var transitFetchArray = [NSManagedObject]()
        
        let managedContext = self.getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trip_id", ascending: false)]
        
        do {
            transitFetchArray = try managedContext.fetch(fetchRequest)
            print("Count is \(transitFetchArray.count)")
            return transitFetchArray.count
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return -1
        }
    }
    
    func getAllData() -> [TripModel]? {
        var tripArray = [TripModel]()
        var transitFetchArray = [NSManagedObject]()
        
        let managedContext = self.getManagedContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TripEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trip_summary_id", ascending: true)]
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            transitFetchArray = try managedContext.fetch(fetchRequest)
            var trip = TripModel()
            
            for transitFetch in transitFetchArray {
                var currentId = 1
                print("Current Id is: \(currentId)")
                let fetchId = transitFetch.value(forKey: "trip_summary_id") as! Int
                
                let transitPath = TransitPath(
                    startLatitude: transitFetch.value(forKey: "trip_lat_start") as! Double,
                    startLongitude: transitFetch.value(forKey: "trip_long_start") as! Double,
                    startTitle: transitFetch.value(forKey: "trip_name_start") as! String?,
                    endLatitude: transitFetch.value(forKey: "trip_lat_end") as! Double,
                    endLongitude: transitFetch.value(forKey: "trip_long_end") as! Double,
                    endTitle: transitFetch.value(forKey: "trip_name_end") as! String?
                )
                
                let transitModel = TransitModel(
                    transitPath: transitPath,
                    carbonEmissionInKg: transitFetch.value(forKey: "trip_carbon_emission") as! Double,
                    costInIDR: transitFetch.value(forKey: "trip_cost") as! Double,
                    type: getTransportType(type: transitFetch.value(forKey: "trip_transport_type") as! Int),
                    distanceInKm: transitFetch.value(forKey: "trip_distance") as! Double,
                    beginDate: transitFetch.value(forKey: "trip_date_start") as! Date,
                    endDate: transitFetch.value(forKey: "trip_date_end") as! Date
                )
                
                if currentId == fetchId {
                    // Current Trip
                    trip.append(transitModel)
                } else if currentId > getLatestSummaryId() {
                    break
                } else {
                    // Next Trip
                    currentId += 1
                    tripArray.append(trip)
                    trip = []
                    trip.append(transitModel)
                }
            }
            
            if tripArray.count == 0 {
                return nil
            }
            return tripArray
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func getTransportType(type: TransportType) -> Int {
        switch type {
        case .car:
            return 0
        case .motor:
            return 1
        case .bus:
            return 2
        case .train:
            return 3
        }
    }
    
    func getTransportType(type: Int) -> TransportType {
        switch type {
        case 0:
            return .car
        case 1:
            return .motor
        case 2:
            return .bus
        case 3:
            return .train
        default:
            return .car
        }
    }
}
