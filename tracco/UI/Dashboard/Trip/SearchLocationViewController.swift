//
//  SearchLocationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 26/06/22.
//

import UIKit
import MapKit
import Speech

@objc protocol SearchLocationDelegate
{
    @objc optional func didSelectLocation(_ map: MKMapItem)
}

class SearchLocationViewController: UIViewController
{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputLocationView: UIView!
    
    public weak var delegate: SearchLocationDelegate?
    public var baseLocation: CLLocation?
    public var baseRegion: MKCoordinateRegion?
    public var isRequestingSpeechDictation = false
    
    private var isSpeechDictationNeedElevation = true
    private var speechDictationVC: SpeechDictationViewController = {
        let vc = SpeechDictationViewController()
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private var alertAuthorization: AppAlertController?
    
    private var dataSource: [MKMapItem]?
    private var searchActor: MKLocalSearch?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        inputLocationView.layer.borderColor = UIColor.label.cgColor
        
        tableView.dataSource = self
        tableView.delegate = self
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(doQueryTextField), for: .editingChanged)
        
        speechDictationVC.delegate = self
        speechDictationVC.modalPresentationStyle = .custom
        speechDictationVC.transitioningDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if isRequestingSpeechDictation
        {
            tryPresentSpeechDictation()
            // if this view controller is a modal, it will trigger this method when
            // user "cancel" dismiss by swipe action. because of that, we should not
            // try to present or in another terms "start" the speech dictation again.
            isRequestingSpeechDictation = false
        }
        else
        {
            textField.becomeFirstResponder()
        }
    }
    
    @IBAction func onBackButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func onMicButton(_ sender: UIButton)
    {
        tryPresentSpeechDictation()
    }
    
    private func tryPresentSpeechDictation()
    {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let micStatus = AVAudioSession.sharedInstance().recordPermission
        
        if (speechStatus == .denied || micStatus == .denied)
        {
            if  alertAuthorization != nil && self.presentedViewController == alertAuthorization
            { return }
            
            let alert = AppAlertController(
                title: "Speech Recognition & Mic",
                message: "Activate speech recognition & microphone in settings to access this feature.",
                image: UIImage(named: "Speech")
            )
            alert.addAction(AppAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
                alert.dismiss(animated: true)
                textField.becomeFirstResponder()
            })
            alert.addAction(AppAlertAction(title: "Go To Settings", style: .default) { _ in
                SystemDevice.openAppSettings()
            })
            self.present(alert, animated: true)
            
            alertAuthorization = alert
        }
        else
        {
            alertAuthorization?.dismiss(animated: true)
            self.present(speechDictationVC, animated: true)
        }
    }
}

extension SearchLocationViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
}

extension SearchLocationViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let data = dataSource?[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as? LocationTableViewCell
        else { return UITableViewCell() }
        
        if let location = data.placemark.location,
           let baseLocation = baseLocation
        {
            let meters = baseLocation.distance(from: location)
            let kilometers = meters * SystemUnits.kilo.rawValue
            let format = kilometers > 10 ? "%.0f km" : "%.1f km"
            cell.distanceLabel.text = String(format: format, kilometers)
        }
        else
        {
            cell.distanceLabel.text = "Unknown"
        }
        
        cell.titleLabel.text = data.placemark.name
        cell.descriptionLabel.text = data.placemark.regionText
        
        return cell
    }
}

extension SearchLocationViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.dismiss(animated: true)
        let data = dataSource![indexPath.row]
        delegate?.didSelectLocation?(data)
    }
}

extension SearchLocationViewController
{
    @objc private func doQueryTextField()
    {
        guard let searchText = textField.text,
              searchText.isEmpty == false
        else
        {
            searchActor?.cancel()
            searchActor = nil
            dataSource = []
            tableView.reloadData()
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = textField.text
        if let baseRegion = baseRegion { searchRequest.region = baseRegion }
        
        if let searchActor = searchActor, searchActor.isSearching
        {
            searchActor.cancel()
        }
        
        searchActor = MKLocalSearch(request: searchRequest)
        searchActor?.start { [weak self] response, error in
            if error != nil { return }
            self?.dataSource = response?.mapItems
            self?.tableView.reloadData()
        }
    }
}

extension SearchLocationViewController: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        let pc = SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        pc.isNeedElevation = isSpeechDictationNeedElevation
        isSpeechDictationNeedElevation = false
        return pc
    }
}

extension SearchLocationViewController: SpeechDictationDelegate
{
    func speechDictation(didFinishRecognizing text: String?)
    {
        textField.text = text
        doQueryTextField()
        textField.resignFirstResponder()
    }
    
    func speechDictation(didCancelRecognizing text: String?)
    {
        textField.becomeFirstResponder()
    }
    
    func speechDictation(didNotAuthorized auth: SFSpeechRecognizerAuthorizationStatus)
    {
        DispatchQueue.main.async { [weak self] in
            self?.speechDictationVC.dismiss(animated: true)
            self?.tryPresentSpeechDictation()
        }
    }
}
