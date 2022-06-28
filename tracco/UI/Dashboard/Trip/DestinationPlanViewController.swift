//
//  DestinationPlanViewController.swift
//  tracco
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
    @IBOutlet weak var checkboxImageView: UIImageView!
    
    var activateLocationVC: AuthorizationSecondaryPlanController?
    
    private var viewModel: DestinationPlanVM?
    private var cancellables: [AnyCancellable]?
    
    private var isUserLocationInitialized = false
    private var isRequestingSpeechDictation = false
    
    private var isDontShowRecommendationAgain = false
    
    private var isSpeechDictationNeedElevation = true
    private var speechDictationVC: SpeechDictationViewController = {
        let vc = SpeechDictationViewController()
        layoutBottomSheet(vc.view)
        return vc
    }()
    
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
        locationManager.allowsBackgroundLocationUpdates = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCheckboxPressed(_:)))
        checkboxImageView.addGestureRecognizer(tapGesture)
        checkboxImageView.isUserInteractionEnabled = true
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func onContinueButton(_ sender: UIButton)
    {
        StoredModel.showRouteRecommendation = !isDontShowRecommendationAgain
    }
    
    @IBAction func onSearchButton(_ sender: SearchSpeechButton, forEvent event: UIEvent)
    {
        isRequestingSpeechDictation = sender.isMicPressed(event: event)
    }
    
    @IBAction func onMoovitButton(_ sender: UIButton)
    {
        if (MoovitAPI.canLink)
        {
            guard let directionURL = MoovitAPI.Direction.getDirectionsFromCurrent(
                origName: "Current Location",
                dest: LocationCoordinate2D(mapView.centerCoordinate),
                destName: viewModel?.titleText
            )
            else
            {
                let alert = UIAlertController(
                    title: "Moovit Invalid URL",
                    message: "App failed to redirect with moovit service",
                    preferredStyle: .actionSheet
                )
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                present(alert, animated: true)
                return
            }
            UIApplication.shared.open(directionURL)
        }
        else
        {
            UIApplication.shared.open(MoovitAPI.moovitAppDownloadURL)
        }
    }
    
    @objc func onCheckboxPressed(_ recognizer: UITapGestureRecognizer)
    {
        isDontShowRecommendationAgain = !isDontShowRecommendationAgain
        let assetName = isDontShowRecommendationAgain ? "checkmark.square" : "square"
        checkboxImageView.image = UIImage(systemName: assetName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SearchLocationViewController
        {
            vc.delegate = self
            vc.baseRegion = mapView.region
            vc.baseLocation = mapView.userLocation.location
            vc.isRequestingSpeechDictation = isRequestingSpeechDictation
        }
    }
}

extension DestinationPlanViewController: AuthorizationSecondaryPlanDelegate
{
    func onCancel()
    {
        self.dismiss(animated: true)
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
    
            let vc = AuthorizationSecondaryPlanController(
                message: "Please allow location access in settings to proceed",
                image: UIImage(named: "Location")
            )
            vc.delegate                 = self
            vc.transitioningDelegate    = AlertPresentationTransitioningManager.shared
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
                viewModel.$regionText.sink(receiveValue: { [unowned self] in locationRegionLabel.text = $0 })
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
            locationDescView.alpha = 0.3
            moovitButton.isEnabled = false
        }
    }
}

extension DestinationPlanViewController: SearchLocationDelegate
{
    func didSelectLocation(_ map: MKMapItem)
    {
        mapView.setCenter(map.placemark.coordinate, animated: true)
    }
}
