//
//  SlidingOnboardingViewController.swift
//  carbonless
//
//  Created by Michael Ricky on 13/06/22.
//

import UIKit

class SlidingOnboardingViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superScrollView: UIView!
    
    let totalPage = 3
    var currentPage = 0
    
    @IBAction func upperButtonTapped(_ sender: UIButton) {
        if currentPage == 2 {
            // Don't scroll to higher index
            performSegue(withIdentifier: "allowNotificationSegue", sender: self)
        } else {
            scrollToNextPage()
        }
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "allowNotificationSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpSlider()
    }
    
    private func setUpSlider() {
        let width = superScrollView.frame.width
        let height = superScrollView.frame.height
        
        scrollView.contentSize = CGSize(width: width * CGFloat(totalPage), height: height)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let currentMode = traitCollection.userInterfaceStyle
        
        for i in 0..<totalPage {
            let imageView: UIImageView
            
            switch currentMode {
            case .unspecified:
                imageView = UIImageView(image: UIImage(named: "OnboardingLight\(i+1)"))
            case .light:
                imageView = UIImageView(image: UIImage(named: "OnboardingLight\(i+1)"))
            case .dark:
                imageView = UIImageView(image: UIImage(named: "OnboardingDark\(i+1)"))
            @unknown default:
                imageView = UIImageView(image: UIImage(named: "OnboardingLight\(i+1)"))
            }
            
            imageView.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: height)
            scrollView.addSubview(imageView)
            imageView.layoutIfNeeded()
        }
    }
    
    private func scrollToNextPage() {
        let width = superScrollView.frame.width
        let height = superScrollView.frame.height
        let nextPage = currentPage + 1
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(nextPage) * width, y: 0, width: width, height: height) ,animated: true)
        currentPage = nextPage
    }
    
    private func updatePage() {
        switch currentPage {
        case 0:
            upperLabel.text = "Choose Your Transportation"
            lowerLabel.text = "Choose what kind of transportations you take for each transit you use"
            upperButton.setTitle("Next", for: .normal)
        case 1:
            upperLabel.text = "Track Your Emmission & Cost"
            lowerLabel.text = "Input your transportations and we’ll count the estimated cost and carbon emmission for you"
            upperButton.setTitle("Next", for: .normal)
        case 2:
            upperLabel.text = "See How Well You Do"
            lowerLabel.text = "Check your profile to see how much your carbon emission and how well you reduce it!"
            upperButton.setTitle("Get Started", for: .normal)
        default:
            upperLabel.text = "Choose Your Transportation"
            lowerLabel.text = "Choose what kind of transportations you take for each transit you use"
            upperButton.setTitle("Next", for: .normal)
        }
    }
}

extension SlidingOnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        currentPage = Int(floor(index))
        pageControl.currentPage = currentPage
        updatePage()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        currentPage = Int(floor(index))
        pageControl.currentPage = currentPage
        updatePage()
    }
}
