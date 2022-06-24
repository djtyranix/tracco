//
//  GlobalPublisher.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 23/06/22.
//

import Foundation

protocol GlobalEvent
{
    func addTripModel(_ model: TripModel)
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
    
    func addTripModel(_ model: TripModel)
    {
        GlobalPublisher.observers.forEach {
            let globalEvent = $0.value as? GlobalEvent
            globalEvent?.addTripModel(model)
        }
    }
}
