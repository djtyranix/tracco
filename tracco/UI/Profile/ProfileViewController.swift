//
//  ProfileViewController.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var emptySumProfileView: UIView!
    @IBOutlet weak var sumProfileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptySumProfileView.isHidden = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
