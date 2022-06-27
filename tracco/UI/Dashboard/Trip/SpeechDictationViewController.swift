//
//  SpeechDictationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 27/06/22.
//

import UIKit
import Speech

@objc protocol SpeechDictationDelegate
{
    @objc optional func speechDictation(didFinishRecognizing text: String?)
    @objc optional func speechDictation(didCancelRecognizing text: String?)
    @objc optional func speechDictation(didNotAuthorized auth: SFSpeechRecognizerAuthorizationStatus)
}

class SpeechDictationViewController: UIViewController
{
    public weak var delegate: SpeechDictationDelegate?
    
    private var isReceivedTranscription = false
    private var audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognizer: SFSpeechRecognizer?
    private var task: SFSpeechRecognitionTask?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var micImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(micImageTapped(tapGestureRecognizer:)))
        micImageView.isUserInteractionEnabled = true
        micImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        isReceivedTranscription = false
        requestPermission()
    }
    
    @objc func micImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.tintColor = .secondaryLabel
        self.dismiss(animated: true)
        delegate?.speechDictation?(didFinishRecognizing: isReceivedTranscription ? label.text : nil)
    }
    
    @IBAction func onCloseButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.speechDictation?(didCancelRecognizing: isReceivedTranscription ? label.text : nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil)
    {
        cancelSpeechRecognition()
        super.dismiss(animated: flag, completion: completion)
    }
    
    private func requestPermission()
    {
        SFSpeechRecognizer.requestAuthorization { [weak self] auth in
            if auth == .denied || auth == .notDetermined
            {
                self?.delegate?.speechDictation?(didNotAuthorized: auth)
                return
            }
            DispatchQueue.main.async { self?.startSpeechRecognition() }
        }
    }
    
    private func startSpeechRecognition()
    {
        label.text = "Speak Now..."
        micImageView.tintColor = UIColor(named: "MainGreen80")
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        audioEngine.prepare()
        
        guard let _ = try? audioEngine.start()
        else
        {
            let alert = UIAlertController(
                title: "Audio Engine Failed",
                message: "Failed to start audio engine for recording",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        recognizer = SFSpeechRecognizer()
        recognizer?.recognitionTask(with: self.request, delegate: self)
    }
    
    private func cancelSpeechRecognition()
    {
        task?.finish()
        task?.cancel()
        task = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

extension SpeechDictationViewController: SFSpeechRecognitionTaskDelegate
{
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription)
    {
        isReceivedTranscription = true
        label.text = transcription.formattedString
    }
}
