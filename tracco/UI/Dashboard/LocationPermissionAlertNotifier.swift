//
//  LocationPermissionAlerter.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 04/07/22.
//

import Foundation
import CoreLocation
import UIKit

class LocationPermissionAlertNotifier: NSObject
{
    public var isAbleToTrack: Bool { get {
        let status = CLLocationManager().authorizationStatus
        return status != .denied && status != .notDetermined
    }}
    
    public weak var parent: UIViewController?
    public var onCancel: (() -> Void)?
    
    private var locationManager: CLLocationManager?
    private var alert: AppAlertController?
    private var isMonitoringState = false
    
    public init(parent: UIViewController?, onCancel: (() -> Void)? = nil)
    {
        self.onCancel = onCancel
        self.parent = parent
    }
    
    public func requestPermission()
    {
        isMonitoringState = false
        if locationManager == nil { locationManager = CLLocationManager() }
        locationManager?.delegate = self
    }
    
    public func startMonitoring()
    {
        isMonitoringState = true
        if locationManager == nil { locationManager = CLLocationManager() }
        locationManager?.delegate = self
    }
    
    public func stopMonitoring()
    {
        locationManager?.delegate = nil
        locationManager = nil
    }
}

extension LocationPermissionAlertNotifier: CLLocationManagerDelegate
{
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        requestWithAlert(manager.authorizationStatus)
    }
    
    // for compatibility version iOS <= 13
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        requestWithAlert(status)
    }
    
    private func requestWithAlert(_ status: CLAuthorizationStatus)
    {
        guard let parent = parent
        else { return }
        
        guard status != .denied
        else
        {
            if alert != nil && parent.presentedViewController === alert
            { return }
    
            let alert = AppAlertController(
                title: "Location Access",
                message: "Activate location access in settings to be able to track your trip.",
                image: UIImage(named: "Location")
            )
            alert.addAction(AppAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
                // disable listener on authorization change if not in monitoring state
                if isMonitoringState == false { self.stopMonitoring() }
                alert.dismiss(animated: true)
                self.onCancel?()
            })
            alert.addAction(AppAlertAction(title: "Go To Settings", style: .default) { _ in
                SystemDevice.openAppSettings()
            })
            parent.present(alert, animated: true)
            
            self.alert = alert
            return
        }
        
        alert?.dismiss(animated: true)
        alert = nil
        
        if status == .notDetermined
        {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
    }
}
