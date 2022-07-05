//
//  GlobalPublisher.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import Foundation
import CoreLocation

protocol GlobalEvent
{
    func tripModelAdded(_ model: TripModel)
    func tripModelUpdated(_ model: TripModel)
    func profileModelUpdated(_ model: ProfileModel)
    
    // MARK: Triggered by OnTripViewController
    
    // feed by CLLocationManagerDelegate (can be in background)
    func onTripLocationUpdate(_ locations: [CLLocation])
    func onTripLocationLost(_ manager: CLLocationManager)
    
    func onTripTransitModelUpdated(_ model: TransitModel)
    func onTripEnded()
    func onTripStarted()
}

// make the method optional without marking as an @objc protocol
extension GlobalEvent
{
    func tripModelAdded(_ model: TripModel) {}
    func tripModelUpdated(_ model: TripModel) {}
    func profileModelUpdated(_ model: ProfileModel) {}
    func onTripLocationUpdate(_ locations: [CLLocation]) {}
    func onTripLocationLost(_ manager: CLLocationManager) {}
    func onTripTransitModelUpdated(_ model: TransitModel) {}
    func onTripEnded() {}
    func onTripStarted() {}
}

class Weak<T: AnyObject>
{
    weak var value : T?
    init (_ value: T) { self.value = value }
}

class GlobalPublisher: GlobalEvent
{
    static var shared = GlobalPublisher()
    
    static private var observers: Array<Weak<AnyObject>> = []
    
    static func addObserver<T: AnyObject>(_ observer: T) where T: GlobalEvent
    {
        let weak = Weak<AnyObject>(observer)
        observers.append(weak)
    }
    
    static func removeObserver<T: AnyObject>(_ observer: T) where T: GlobalEvent
    {
        // refer to the same instance
        observers.removeAll(where: { $0.value === observer })
    }
    
    func tripModelAdded(_ model: TripModel)
    {
        publish { $0.tripModelAdded(model) }
    }
    
    func profileModelUpdated(_ model: ProfileModel)
    {
        publish { $0.profileModelUpdated(model) }
    }
    
    func tripModelUpdated(_ model: TripModel)
    {
        publish { $0.tripModelUpdated(model) }
    }
    
    func onTripLocationUpdate(_ locations: [CLLocation])
    {
        publish { $0.onTripLocationUpdate(locations) }
    }
    
    func onTripLocationLost(_ manager: CLLocationManager)
    {
        publish { $0.onTripLocationLost(manager) }
    }
    
    func onTripTransitModelUpdated(_ model: TransitModel)
    {
        publish { $0.onTripTransitModelUpdated(model) }
    }
    
    func onTripStarted()
    {
        publish { $0.onTripStarted() }
    }
    
    func onTripEnded()
    {
        publish { $0.onTripEnded() }
    }

    private func publish(_ callback: (GlobalEvent) -> Void)
    {
        GlobalPublisher.observers.forEach {
            let globalEvent = $0.value as! GlobalEvent
            callback(globalEvent)
        }
    }
}
