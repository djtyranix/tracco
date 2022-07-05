//
//  SlidingOnboardingViewController.swift
//  tracco
//
//  Created by Michael Ricky on 13/06/22.
//

import UIKit

class SlidingOnboardingViewController: UIViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var upperButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let allowNotificationSegueId = "allowNotificationSegue"
    let totalPage = 3
    
    private var currentPage = 0
    
    @IBAction func upperButtonTapped(_ sender: UIButton)
    {
        // allow scroll until the end of index of pages
        currentPage == (totalPage - 1) ? performSegue(withIdentifier: allowNotificationSegueId, sender: self) : scrollToNextPage()
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton)
    {
        performSegue(withIdentifier: allowNotificationSegueId, sender: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updatePage()
        scrollView.delegate = self
    }
    
    private func scrollToNextPage()
    {
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        let nextPage = currentPage + 1
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(nextPage) * width, y: 0, width: width, height: height) ,animated: true)
        currentPage = nextPage
    }
    
    private func updatePage()
    {
        let isLastPage = currentPage == totalPage - 1
        skipButton.isHidden = isLastPage
        
        let buttonText = isLastPage ? "Get Started" : "Next"
        upperButton.setTitle(buttonText, for: .normal)
        
        if (currentPage == 0)
        {
            upperLabel.text = "Choose Transportation"
            lowerLabel.text = "Choose what kind of transportations you take for each transit of the trip"
        }
        else if (currentPage == 1)
        {
            upperLabel.text = "Track Your Emmission"
            lowerLabel.text = "Start your trip and we’ll count the estimated cost and carbon emmission"
        }
        else
        {
            upperLabel.text = "See How Well You Do"
            lowerLabel.text = "Check your profile to see how well you reduce it and share with others"
        }
    }
}

extension SlidingOnboardingViewController: UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { scrollViewDidEndScroll() }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) { scrollViewDidEndScroll() }
    
    private func scrollViewDidEndScroll()
    {
        let index = scrollView.contentOffset.x / scrollView.frame.size.width
        currentPage = Int(floor(index))
        pageControl.currentPage = currentPage
        updatePage()
    }
}
