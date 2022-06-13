//
//  OnTripViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit
import MapKit
import Combine

fileprivate func layoutBottomSheet(_ view: UIView)
{
    view.backgroundColor        = .systemBackground
    view.layer.cornerRadius     = 25
    view.layer.maskedCorners    = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
}

class OnTripViewController: UIViewController
{
    private let chooseTransportationVC: ChooseTransportationViewController = {
        let vc = ChooseTransportationViewController(TransportType.allCases)
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let changeTransportationVC: ChangeTransportViewController = {
        let vc = ChangeTransportViewController(TransportType.allCases)
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let costTransportationVC: TransportationCostViewController = {
        let vc = TransportationCostViewController()
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let currentTransportationVC: CurrentTransportationViewController = {
        let vc = CurrentTransportationViewController()
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private var transits: [TransitPath] = []
    private var viewModel: OnTripVM?
    private var cancellables: [AnyCancellable]?
    private var timerUpdate: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // delegation (event handler)
        mapView.delegate                    = self
        locationManager.delegate            = self
        currentTransportationVC.delegate    = self
        costTransportationVC.delegate       = self
        chooseTransportationVC.delegate     = self
        changeTransportationVC.delegate     = self
        
        // presentation controller will disabled input from container vc
        chooseTransportationVC.transitioningDelegate    = self
        costTransportationVC.transitioningDelegate      = self
        changeTransportationVC.transitioningDelegate    = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        present(chooseTransportationVC, animated: true) { [unowned self] in
            // set bottom constraint to adjust the center of the map after adding CurrentTransportation view from the bottom
            UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseIn) { [unowned self] in
                mapViewBottomConstraint.constant = 330
            }
            // current transporation view always exists on the bottom of the container view
            currentTransportationVC.view.frame = SheetPresentationController.getFrameOfPresentedViewInContainerView(
                currentTransportationVC.view,
                containerView: self.view
            )
            self.view.addSubview(currentTransportationVC.view)
        }
    }
    
    @objc func onUpdate()
    {
        viewModel?.currentLocation = mapView.userLocation.location!
        
        guard let currLocation = viewModel?.currentLocation
        else { return }
        
        guard let prevLocation = viewModel?.previousLocation
        else { return }
        
        let polyline = MKPolyline(coordinates: [prevLocation.coordinate, currLocation.coordinate], count: 2)
        mapView.addOverlay(polyline, level: .aboveRoads)
    }
    
    private func updateTransportation(_ selected: TransportRadioButton?)
    {
        let currCoordinate = mapView.userLocation.coordinate
        let currentType = TransportType.allCases[chooseTransportationVC.radioButton!.selectedIndex]
        
        let viewModel = OnTripVM(currentType, currentLocation: mapView.userLocation.location!)
        self.viewModel = viewModel
        
        cancellables = [
            viewModel.$distanceInKmText.sink(receiveValue: { [unowned self] in currentTransportationVC.distanceLabel.text = $0 }),
            viewModel.$totalCostInIDRText.sink(receiveValue: { [unowned self] in currentTransportationVC.approxCostLabel.text = $0 }),
            viewModel.$carbonEmissionInKgText.sink(receiveValue: { [unowned self] in currentTransportationVC.carbonEmissionLabel.text = $0 })
        ]
        
        let transit = TransitPath(type: currentType, data: [mapView.userLocation.coordinate])
        let annotation = TransportAnnotation(coordinate: currCoordinate, subtitle: "...", type: currentType)
        transits.append(transit)
        mapView.addAnnotation(annotation)
        
        currentTransportationVC.imageView.image = selected?.image
        currentTransportationVC.nameLabel.text = selected?.title
        
        if (timerUpdate == nil)
        {
            timerUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
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
            renderer.strokeColor = viewModel?.transportType.color
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
    func onConfirmChoose(_ selected: TransportRadioButton?)
    {
        updateTransportation(selected)
    }
}

// MARK: ChangeTransportViewControllerDelegate
extension OnTripViewController: ChangeTransportViewControllerDelegate
{
    func onConfirmChange(_ selected: TransportRadioButton?)
    {
        updateTransportation(selected)
    }
}

// MARK: TransportationCostViewControllerDelegate
extension OnTripViewController: TransportationCostViewControllerDelegate
{
    func onConfirmCost(_ cost: Int)
    {
        present(changeTransportationVC, animated: true)
    }
}

// MARK: TransitioningDelegate
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
