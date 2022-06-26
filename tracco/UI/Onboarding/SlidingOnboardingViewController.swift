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
        let isLastPage = currentPage == 2
        skipButton.isHidden = isLastPage
        
        if let attributedTitle = upperButton.attributedTitle(for: .normal)
        {
            let buttonText = isLastPage ? "Get Started" : "Next"
            let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
            mutableAttributedTitle.replaceCharacters(
                in: NSMakeRange(0, mutableAttributedTitle.length),
                with: buttonText
            )
            upperButton.setAttributedTitle(mutableAttributedTitle, for: .normal)
        }
        
        if (currentPage == 0)
        {
            upperLabel.text = "Choose Your Transportation"
            lowerLabel.text = "Choose what kind of transportations you take for each transit you use"
        }
        else if (currentPage == 1)
        {
            upperLabel.text = "Track Your Emmission & Cost"
            lowerLabel.text = "Input your transportations and we’ll count the estimated cost and carbon emmission for you"
        }
        else
        {
            upperLabel.text = "See How Well You Do"
            lowerLabel.text = "Check your profile to see how much your carbon emission and how well you reduce it!"
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
