//
//  ShareViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 24/06/22.
//

import UIKit

class ShareViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topConstraintView: UILabel!
    @IBOutlet weak var bottomConstraintView: UILabel!
    
    public var imageContent: UIImage?
    public var imageContentSize: CGSize?
    public var onViewDidAppear: (() -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
            
        let imageView = UIImageView(image: imageContent)
        scrollView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topConstraintView.bottomAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: bottomConstraintView.topAnchor, constant: -16),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        if let imageContentSize = imageContentSize
        {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageContentSize.width),
                imageView.heightAnchor.constraint(equalToConstant: imageContentSize.height)
            ])
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        onViewDidAppear?()
    }
    
    func snapshot() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, 0.0)

        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame

        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return nil }
        
        scrollView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame

        UIGraphicsEndImageContext()

        return image
    }
}
