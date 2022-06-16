//
//  OnTripViewController.swift
//  tracco
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
        vc.view.addDoneButton(textField: vc.textField, alignment: .right)
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
    
    private var isCostViewElevated = false { didSet {
        if (isCostViewElevated == oldValue) { return }
        // height should be cover the button and should revert back to original state
        // this will handle cases for simulator keyboard toggle (keyboard size not fixed)
        let costViewFloatingHeight = view.frame.height - costTransportationVC.view.frame.maxY
        let isCostViewFloating = costViewFloatingHeight != 0
        let heightToMove: CGFloat = isCostViewFloating ? costViewFloatingHeight : -(keyboardHeight - 120)
        costTransportationVC.view.frame.origin.y += heightToMove
    }}
    
    private let trackingModeFollowImage: UIImage? = {
        let image = "location.fill"
        let config = UIImage.SymbolConfiguration(scale: .medium)
        return UIImage(systemName: image, withConfiguration: config)
    }()
    
    private let trackingModeNofollowImage: UIImage? = {
        let image = "location"
        let config = UIImage.SymbolConfiguration(scale: .medium)
        return UIImage(systemName: image, withConfiguration: config)
    }()
    
    private var keyboardHeight: CGFloat = 210
    
    private var transits: [TransitPath] = []
    private var viewModel: OnTripVM?
    private var cancellables: [AnyCancellable]?
    private var timerUpdate: Timer?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    
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
        
        // add observer to handle keyboard covering cost view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
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
    
    @IBAction func onBackButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @IBAction func onLocationButton(_ sender: UIButton)
    {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    @objc func onUpdate()
    {
        let image = mapView?.userTrackingMode == .follow ? trackingModeFollowImage : trackingModeNofollowImage
        locationButton.setImage(image, for: .normal)
        
        viewModel?.currentLocation = mapView.userLocation.location!
        
        guard let currLocation = viewModel?.currentLocation
        else { return }
        
        guard let prevLocation = viewModel?.previousLocation
        else { return }
        
        let polyline = MKPolyline(coordinates: [prevLocation.coordinate, currLocation.coordinate], count: 2)
        mapView.addOverlay(polyline, level: .aboveRoads)
    }
    
    private func updateTransportation(_ manager: RadioButtonManager<TransportRadioButton>)
    {
        let currCoordinate = mapView.userLocation.coordinate
        let currentType = TransportType.allCases[manager.selectedIndex]
        
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
        
        let selectedRadioButton = manager.selected
        currentTransportationVC.imageView.image = selectedRadioButton?.image
        currentTransportationVC.nameLabel.text = selectedRadioButton?.title
        
        if (timerUpdate == nil)
        {
            timerUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
        }
    }
}

extension OnTripViewController
{
    // this method can be called twice even though keyboard already showed up
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        isCostViewElevated = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        isCostViewElevated = false
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
        costTransportationVC.viewModel = TransportationCostVM(
            viewModel?.totalCostInIDR ?? 0,
            useApproximation: true
        )
        present(costTransportationVC, animated: true)
    }
    
    func onEndTripButton(_ sender: UIButton)
    {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "Confirm arrival at final destination? This action cannot be undone",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "I'm Arrived", style: .default) { _ in
            self.view.window?.rootViewController?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: ChooseTransportationViewControllerDelegate
extension OnTripViewController: ChooseTransportationViewControllerDelegate
{
    func onConfirmChoose(_ selected: TransportRadioButton?)
    {
        updateTransportation(chooseTransportationVC.radioButton!)
    }
}

// MARK: ChangeTransportViewControllerDelegate
extension OnTripViewController: ChangeTransportViewControllerDelegate
{
    func onConfirmChange(_ selected: TransportRadioButton?)
    {
        updateTransportation(changeTransportationVC.radioButton!)
    }
}

// MARK: TransportationCostViewControllerDelegate
extension OnTripViewController: TransportationCostViewControllerDelegate
{
    func onConfirmCost(_ cost: Double)
    {
        print(cost)
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
