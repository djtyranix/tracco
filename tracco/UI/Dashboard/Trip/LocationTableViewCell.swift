//
//  LocationTableViewCell.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 26/06/22.
//

import UIKit

class LocationTableViewCell: UITableViewCell
{
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
