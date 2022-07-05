//
//  NotificationTrigger.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 04/07/22.
//

import Foundation
import UIKit
import NotificationCenter
import MapKit

@propertyWrapper
struct StaticNotification
{
    let key: String
    let wrappedValue: NotificationContent
}

struct NotificationContent
{
    var title: String
    var message: String
    
    var content: UNNotificationContent { get {
        let content = UNMutableNotificationContent()
        content.title = self.title
        content.badge = 1
        content.body  = self.message
        content.sound = .default
        return content
    }}
}

class NotificationTrigger: NSObject
{
    static var shared: NotificationTrigger = .init()
    
    @StaticNotification(key: "0", wrappedValue: NotificationContent(
        title: "Have you arrived yet? 🤔",
        message: "Don’t forget to end your trip to track your carbon emission! 🌲"
    ))
    var arrivalCertaintyNotificationContent
    
    @StaticNotification(key: "1", wrappedValue: NotificationContent(
        title: "We couldn’t track your location",
        message: "Check your location and connection. Please try again so we can continue tracking your trip!"
    ))
    var trackingLostNotificationContent
    
    @StaticNotification(key: "2", wrappedValue: NotificationContent(
        title: "Where are you going today? 🚞",
        message: "Start your day right! Don’t forget to count your carbon emission with Tracco 🌲"
    ))
    var callToUseNotificationContent
    
    @StaticNotification(key: "3", wrappedValue: NotificationContent(
        title: "We haven’t seen you for a while 😢",
        message: "Start your day right! Don’t forget to count your carbon emission with Tracco 🌲"
    ))
    var longAbsentNotificationContent
    
    // contain the previous location of the user for every movement
    // that is >= proximityArrivalCertainty
    private var locationCheckpointArrivalCertainty: CLLocation?
    
    // ask the user about certainty of the arrival if user
    // hasn't been moved for this distance since (locationCheckpointArrivalCertainty)
    // this will handle the cases where user is moving inside building
    private let proximityArrivalCertainty: CLLocationDistance = 200
    
    // the app will notify the user about the certainty of the arrival if
    // user doesn't move for proximityArrivalCertainty for this long
    private let intervalArrivalCertainty: TimeInterval = 10 * 60
    
    // the app will notify the user to encouragement them to use the app
    // for every watching date component of this
    private let dateCallToUse: DateComponents = {
        var components      = DateComponents(calendar: Calendar.current)
        components.hour     = 07
        components.minute   = 00
        return components
    }()
    
    // tell the user he's been long gone not using the app
    // ie: if they absent for this long
    private let intervalLongAbsent: TimeInterval = 7 * 24 * 60 * 60
    
    override init()
    {
        super.init()
        GlobalPublisher.addObserver(self)
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func notifyUserOpen()
    {
        // daily notification to use the app
        ({
            let identifier = _callToUseNotificationContent.key
            let content = callToUseNotificationContent.content
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCallToUse, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        })()
        // retrigger the absent interval notification
        ({ [unowned self] in
            let identifier = _longAbsentNotificationContent.key
            let content = longAbsentNotificationContent.content
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalLongAbsent, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        })()
    }
    
    public func notifyLocationUpdate(_ location: CLLocation)
    {
        // if user hasn't been moved for proximityArrivalCertainty
        // the interval of notification will not be updated
        if  let locationCheckpointArrivalCertainty = locationCheckpointArrivalCertainty,
            location.distance(from: locationCheckpointArrivalCertainty) < proximityArrivalCertainty
            { return }
        
        let notifcenter = UNUserNotificationCenter.current()
        
        // remove all notification if user start his trip or detects location update
        // meaning that [1] locations not lost ans [2] he's not arrived yet
        let expiringTriggerIdentifiers = [
            _arrivalCertaintyNotificationContent.key,
            _trackingLostNotificationContent.key
        ]
        notifcenter.removeDeliveredNotifications(withIdentifiers: expiringTriggerIdentifiers)
        
        // recreate the notification request if location gets updated
        // notification center will replaces the old request with the new one
        // thus updating the time interval via the trigger
        let identifier = _arrivalCertaintyNotificationContent.key
        let content = arrivalCertaintyNotificationContent.content
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalArrivalCertainty, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notifcenter.add(request)
        
        locationCheckpointArrivalCertainty = location
    }
    
    public func removeLocationUpdateNotification()
    {
        locationCheckpointArrivalCertainty = nil
        let identifier = _arrivalCertaintyNotificationContent.key
        let notifcenter = UNUserNotificationCenter.current()
        notifcenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notifcenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    public func notifyLocationLost()
    {
        // send notification immediately
        let identifier = _trackingLostNotificationContent.key
        let content = trackingLostNotificationContent.content
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

extension NotificationTrigger: UNUserNotificationCenterDelegate
{}

extension NotificationTrigger: GlobalEvent
{
    // make sure to be lightweight because this can be run in background
    func onTripLocationUpdate(_ locations: [CLLocation])
    {
        if let location = locations.last { self.notifyLocationUpdate(location) }
    }
    
    func onTripEnded()
    {
        self.removeLocationUpdateNotification()
    }
    
    func onTripLocationLost(_ manager: CLLocationManager)
    {
        self.notifyLocationLost()
    }
}
