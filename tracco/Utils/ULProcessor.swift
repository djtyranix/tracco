//
//  ULProcessor.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 03/07/22.
//

import Foundation
import CoreLocation

protocol ULProcessorDelegate: AnyObject
{
    func location(_ processor: ULProcessor, didRefactor index: Int)
    func location(_ processor: ULProcessor, didAdd location: CLLocation)
}

/// Update Location Processor is a class to filter location updates from CLLocation
class ULProcessor
{
    public weak var delegate: ULProcessorDelegate?
    
    public let sampleSize: Int
    public let minDistanceMovement: CLLocationDistance

    private(set) var sample: [CLLocation]
    
    public init(sampleSize: Int, minDistanceMovement: Double)
    {
        self.sampleSize = sampleSize
        self.minDistanceMovement = minDistanceMovement
        sample = []
    }
    
    public func update(_ location: CLLocation)
    {
        processScenario1(location)
        processScenario2()
    }
    
    /*
     *  process a location to be updated in sample
     *
     *  Discussion:
     *      This scenario will try to meet the following requirements:
     *      1:  sample only updated when the distance from previous location
     *          is greater or equal with minDistanceMovement
     *      2:  if has no previous location, immediately included in sample
     *
     */
    private func processScenario1(_ location: CLLocation)
    {
        // guard clause, return if not meet the requirements
        if let prevLocation = sample.last
        {
            let distance = prevLocation.distance(from: location)
            if distance < minDistanceMovement { return }
        }
        // limit the sample by discarding the oldest
        if sample.count == sampleSize { sample.removeFirst() }
        sample.append(location)
        delegate?.location(self, didAdd: location)
    }
    
    /*
     *  TODO: add implementation
     *
     *  process a sample to be refactor when reach full capacity and detects an anomaly.
     *  the size of sample should >= 5 to be evaluated in this method. Otherwise it will
     *  not be accurate and become useless.
     *
     *  Discussion:
     *      This scenario will try to meet the following requirements:
     *      1:  the movement of middle element in the sample should be align
     *          with the movement from it's LHS and RHS
     *
     */
    private func processScenario2()
    {
        if sampleSize < 5 || sample.count != sampleSize
        {
            return
        }
        let index = sampleSize / 2
        delegate?.location(self, didRefactor: index)
    }
}
