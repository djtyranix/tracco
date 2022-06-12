//
//  OnTripViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit
import MapKit

fileprivate func layoutBottomSheet(_ view: UIView)
{
    view.backgroundColor        = .systemBackground
    view.layer.cornerRadius     = 25
    view.layer.maskedCorners    = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
}

class OnTripViewController: UIViewController
{
    private let chooseTransportationVC: ChooseTransportationViewController = {
        // choose transport for the first time
        let vc = ChooseTransportationViewController(nil)
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let costTransportationVC: TransportationCostViewController = {
        // choose transport for the first time
        let vc = TransportationCostViewController()
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let currentTransportationVC: CurrentTransportationViewController = {
        // choose transport for the first time
        let vc = CurrentTransportationViewController()
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // delegation (event handler)
        currentTransportationVC.delegate = self
        costTransportationVC.delegate = self
        chooseTransportationVC.delegate = self
        
        // presentation controller will disabled input from container vc
        chooseTransportationVC.transitioningDelegate = self
        costTransportationVC.transitioningDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        present(chooseTransportationVC, animated: true) { [unowned self] in
            // current transporation view always exists on the bottom of the container view
            currentTransportationVC.view.frame = SheetPresentationController.getFrameOfPresentedViewInContainerView(
                currentTransportationVC.view,
                containerView: self.view
            )
            self.view.addSubview(currentTransportationVC.view)
        }
    }
}


// MARK: MKMapViewDelegate
extension OnTripViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            return renderer
        }
        if overlay is MKTileOverlay
        {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: CLLocationManagerDelegate
extension OnTripViewController: CLLocationManagerDelegate
{
    
}

// MARK: CurrentTransportationViewControllerDelegate
extension OnTripViewController: CurrentTransportationViewControllerDelegate
{
    func onChangeTransportationButton(_ sender: UIButton)
    {
        present(costTransportationVC, animated: true)
    }
    
    func onEndTripButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
}

// MARK: ChooseTransportationViewControllerDelegate
extension OnTripViewController: ChooseTransportationViewControllerDelegate
{
    func onConfirmChanges(_ selected: TransportRadioButton?)
    {
        
    }
}

// MARK: TransportationCostViewControllerDelegate
extension OnTripViewController: TransportationCostViewControllerDelegate
{
    func onConfirmCost(_ cost: Int)
    {
        present(chooseTransportationVC, animated: true)
    }
}

extension OnTripViewController: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
