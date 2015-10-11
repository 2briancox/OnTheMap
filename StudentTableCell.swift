//
//  StudentTableCell.swift
//  OnTheMap
//
//  Created by Brian on 10/10/15.
//  Copyright © 2015 Rainien.com, LLC. All rights reserved.
//

import UIKit

class StudentTableCell: UITableViewCell {

    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
