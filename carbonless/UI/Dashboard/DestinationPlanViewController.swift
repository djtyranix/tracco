//
//  DestinationPlanViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit
import MapKit
import Combine

// TODO: Create "don't show this recommendation" checkbox handler

class DestinationPlanViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var moovitButton: UIButton!
    
    @IBOutlet weak var locationDescView: UIView!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationRegionLabel: UILabel!
    @IBOutlet weak var locationCoordinateLabel: UILabel!
    
    var activateLocationVC: ActivateLocationViewController?
    
    private var viewModel: DestinationPlanVM?
    private var cancellables: [AnyCancellable]?
    
    private var isUserLocationInitialized = false
    private let locationSettingsURL = URL(string: "App-Prefs:root=Privacy&path=LOCATION")!
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func onContinueButton(_ sender: UIButton)
    {
        
    }
    
    @IBAction func onMoovitButton(_ sender: UIButton)
    {
        if (MoovitAPI.canLink)
        {
            guard let directionURL = MoovitAPI.Direction.getDirectionsFromCurrent(
                origName: "Current Location",
                dest: mapView.centerCoordinate,
                destName: viewModel?.titleText
            )
            else
            {
                print("url moovit not valid")
                return
            }
            UIApplication.shared.open(directionURL)
            moovitButton.setTitle("Continue Trip", for: .normal)
        }
        else
        {
            UIApplication.shared.open(MoovitAPI.moovitAppDownloadURL)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
    }
}

extension DestinationPlanViewController: ActivateLocationViewControllerDelegate
{
    func onGoToSettings()
    {
        if let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            let url = locationSettingsURL.appendingPathComponent(bundleIdentifier, isDirectory: true)
            print(url)
            UIApplication.shared.open(url)
        }
        else
        {
            UIApplication.shared.open(locationSettingsURL)
        }
    }
}

extension DestinationPlanViewController: CLLocationManagerDelegate
{
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        determineLocationAlert(manager.authorizationStatus)
    }
    
    // for compatibility version iOS <= 13
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        determineLocationAlert(status)
    }
    
    private func determineLocationAlert(_ status: CLAuthorizationStatus)
    {
        if (status == .denied)
        {
            if let vc = activateLocationVC, vc.isBeingPresented { return }
            
            let vc = ActivateLocationViewController()
            vc.delegate                 = self
            vc.transitioningDelegate    = self
            vc.modalPresentationStyle   = .custom
            vc.view.layer.cornerRadius  = 12
            present(vc, animated: true)
            activateLocationVC = vc
        }
        else
        {
            activateLocationVC?.dismiss(animated: true)
        }
    }
}

extension DestinationPlanViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation)
    {
        if (isUserLocationInitialized == false)
        {
            let userCoord       = userLocation.coordinate
            let targetLocation  = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
            let viewModel       = DestinationPlanVM(targetLocation)
            self.viewModel      = viewModel
            
            cancellables = [
                viewModel.$titleText.sink(receiveValue: { [unowned self] in locationTitleLabel.text = $0 }),
                viewModel.$regionText.sink(receiveValue: { [unowned self] in locationRegionLabel.text = $0 }),
                viewModel.$coordinateText.sink(receiveValue: { [unowned self] in locationCoordinateLabel.text = $0 })
            ]
            
            let span    = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region  = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            isUserLocationInitialized = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        // animation
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [unowned self] in
            mapPinView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            locationDescView.backgroundColor = .systemBackground
            locationDescView.alpha = 1.0
            moovitButton.isEnabled = true
        }
        // logic
        let centerLatitude          = mapView.centerCoordinate.latitude
        let centerLongitude         = mapView.centerCoordinate.longitude
        viewModel?.targetLocation   = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        // animation
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [unowned self] in
            mapPinView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            locationDescView.backgroundColor = .darkGray
            locationDescView.alpha = 0.4
            moovitButton.isEnabled = false
        }
    }
}

extension DestinationPlanViewController: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        let presentation = AlertPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        presentation.inset = 20.0
        return presentation
    }
}
