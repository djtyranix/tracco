//
//  ShareOptionViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 25/06/22.
//

import UIKit

class ShareOptionViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    
    public var image: UIImage?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        guard let image = image
        else
        {
            shareButton.isEnabled = false
            saveImageButton.isEnabled = false
            return
        }
        imageView.image = image
    }

    @IBAction func onShareButton(_ sender: UIButton)
    {
        // set up activity view controller
        let imageToShare = [image!]
        let activityViewController = UIActivityViewController(
            activityItems: imageToShare,
            applicationActivities: nil
        )
        // so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceView = self.view
        // present the view controller
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func onSaveAsImageButton(_ sender: UIButton)
    {
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(completionSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func completionSaveImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error
        {
            showAlertWith(title: "Save Error", message: error.localizedDescription)
        }
        else
        {
            showAlertWith(title: "Saved", message: "Your image has been saved to your photo library")
        }
    }
    
    func showAlertWith(title: String, message: String)
    {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
